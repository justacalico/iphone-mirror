# Architecture

## Process model

Three logical components, two processes:

```
+---------------------------+        +---------------------------+
|        iPhone             |        |        Linux PC           |
|                           |        |                           |
|  Screen Mirroring  ----WiFi RTP/RTSP---->  uxplay (child proc)  |
|                           |        |        |                  |
|                           |        |        | RTP H.264 over   |
|                           |        |        | loopback UDP     |
|  AssistiveTouch    <---BLE GATT HID----|    v                  |
|  (Settings pairs PC                |  +------------------+     |
|   as BT device)                    |  | iphone-mirror    |     |
|                                    |  | (Flutter app)    |     |
|  CoreDevice HID   <---USB/RemoteXPC-|  |                  |     |
|  (iOS 17+, Developer Mode)   |     |  |  GStreamer appsrc|     |
|                              |     |  |  -> texture      |     |
|                              |     |  |  InputBackend    |     |
|                              |     |  |  BlueZ via D-Bus |     |
|                              |     |  +------------------+     |
|                              |     |        ^                  |
|                              |     |  pymobiledevice3 sidecar  |
|                              |     |  (optional, USB path)     |
+---------------------------+  |     +---------------------------+
                               |
                               +--- unix socket / JSON-lines
```

- **uxplay** runs as a managed child process of the app, never as a system
  daemon by default. The app owns its lifecycle, argv, stdout log parsing,
  and restart policy.
- **iphone-mirror** is one Flutter desktop process. It contains:
  - the Dart UI,
  - a small Linux platform plugin in C that owns the GStreamer decode
    pipeline and registers the video texture,
  - a Dart `InputBackend` layer. The BLE backend talks to BlueZ over the
    system D-Bus directly from Dart. The USB backend proxies a local
    pymobiledevice3 sidecar over a JSON-lines unix socket.
- **pymobiledevice3 sidecar** only exists when the USB backend is selected.
  It is spawned on demand and killed when the app exits.

## Why uxplay stays a subprocess

- UxPlay is a C program with global state and a decade of protocol edge cases
  baked in (FairPlay handshake, SRP pairing, NTP sync, retransmit). Linking it
  buys nothing except crash surface inside our GUI process.
- It already has every switch we need: fixed ports, PIN, client ACLs, and the
  `-vrtp` / `-artp` flags that forward the decoded stream to an arbitrary
  GStreamer pipeline endpoint. We never patch its internals.
- License stays clean: we bundle/depend on a GPLv3 binary, we are AGPLv3, no
  ambiguity, and a system-installed uxplay can be swapped in.
- If uxplay crashes, the app reports "receiver crashed, restart?" instead of
  dying.

Cost: we depend on its release cadence and a distro package existing. Mitigated
by supporting a vendored binary and by keeping all uxplay-specific knowledge in
one `ReceiverManager` class.

## Why BLE HID goes through BlueZ D-Bus, not a helper

The reference implementation (AirBridge) uses Python `bluez-peripheral`, which
is itself a thin wrapper over two BlueZ APIs:

- `org.bluez.LEAdvertisingManager1` (register an LE advert)
- `org.bluez.GattManager1` (register a local GATT service tree)

Both are plain D-Bus. Dart's `dbus` package can call methods and export local
objects (needed for `GattService1`/`GattCharacteristic1` and
`GetManagedObjects`). Doing it in Dart keeps the whole control path inside the
app process: no Python dependency, no second daemon, no extra IPC hop.

The one thing BlueZ requires is a pairing agent
(`org.bluez.AgentManager1` / `Agent1`) so the iPhone can bond to us without a
desktop Bluetooth applet. The app registers one with `NoInputNoOutput`
capability (HID bonds are JustWorks on the iOS side) and, where the UI is
running, routes any unexpected confirmation to a Flutter dialog.

## IPC contracts

### uxplay <-> app

- argv in, stdout/stderr out. UxPlay logs connection events
  (`connection accepted`, client name, teardown) which drive UI state.
- Video: `-vrtp "<payloader opts> ! udpsink host=127.0.0.1 port=$PORT"`.
- Audio: left to uxplay's own renderer in v1 (see 03-video-pipeline.md).

### app <-> input backends

One internal Dart interface (defined in 06):

```dart
abstract class InputBackend {
  Future<void> move(int dx, int dy);
  Future<void> absoluteMove(double x, double y); // normalized 0..1
  Future<void> button(PointerButton b, bool pressed);
  Future<void> scroll(double dx, double dy);
  Future<void> keyEvent(HidKey key, bool pressed, {int modifiers});
  Future<void> text(String s);
  Future<void> systemAction(SystemAction a); // Home, AppSwitcher, Spotlight, Siri
  Stream<BackendState> get state; // unpaired, advertising, connected, error
}
```

### app <-> pymobiledevice3 sidecar

JSON lines over `$XDG_RUNTIME_DIR/iphone-mirror/usb-input.sock`, mode 0600.
Same message vocabulary as the AirBridge control socket (proven shape):

```json
{"type":"absolute","x":0.5,"y":0.32,"touched":true}
{"type":"key","usage":41,"modifier":0}
{"type":"button","name":"home"}
{"type":"status"}
```

The sidecar speaks this protocol natively (small Python shim around
pymobiledevice3's `UniversalHIDService`), so the Dart backend is a socket
client and stays transport-agnostic.

## Component map

| Component | Language | Lives in | Depends on |
|---|---|---|---|
| Flutter UI | Dart | `lib/` | flutter |
| Video decode + texture | C (plugin) | `linux/` | gstreamer-1.0, gst-app, gst-video |
| ReceiverManager | Dart | `lib/receiver/` | uxplay binary |
| BleInputBackend | Dart | `lib/input/` | dbus pkg, BlueZ >= 5.66 |
| UsbInputBackend | Dart | `lib/input/` | sidecar socket |
| usb-input sidecar | Python | `sidecar/` | pymobiledevice3 |
| Pairing agent | Dart | `lib/bt/` | dbus pkg |
| Settings/storage | Dart | `lib/core/` | shared_preferences |

## Failure and restart policy

- uxplay exits: read exit code + last log lines, classify (port in use, mDNS
  conflict, GStreamer plugin missing), show actionable error, offer restart.
- BlueZ not present or adapter off: input panel shows "Bluetooth unavailable",
  mirror still works.
- Sidecar missing or dies: USB backend greys out, BLE remains.
- No pairing: input events queue-drop silently, UI shows pairing instructions.
