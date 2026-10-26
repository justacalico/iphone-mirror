# Flutter app

## Why Flutter here

- One UI codebase if the app ever goes to Windows (uxplay-windows exists, the
  BLE story there is worse but not impossible).
- Desktop Linux support is stable for a single-window utility app.
- The texture API is enough for a 60 fps video widget.
- D-Bus is a pure-Dart dependency (`dbus` package), so the entire BLE control
  path stays in the main process.

## Layout

```
lib/
  main.dart
  app.dart                  # MaterialApp, theme, routes
  pages/
    mirror_page.dart        # video + toolbar + cursor overlay
    pairing_page.dart       # onboarding wizard (BLE) / USB setup
    settings_page.dart      # receiver, video, input, advanced
    diagnostics_page.dart   # self-test output, logs
  receiver/
    receiver_manager.dart   # uxplay lifecycle, argv builder, log parse
    receiver_settings.dart
  video/
    mirror_texture.dart     # channel wrapper, dimensions stream
  input/
    input_backend.dart      # abstract interface
    ble_hid_backend.dart    # BlueZ D-Bus implementation
    usb_input_backend.dart  # sidecar socket implementation
    input_router.dart       # picks backend, exposes unified state
    hid_codes.dart          # usage tables, report builders
    coordinate_map.dart     # letterbox -> normalized -> 0..32767
  bt/
    gatt_server.dart        # DBusObject tree for HID services
    advert.dart             # LEAdvertisingManager1 wrapper
    pairing_agent.dart      # Agent1 implementation
    adapter.dart            # power/pairable/discoverable mgmt
  core/
    settings.dart           # shared_preferences backed
    log.dart
linux/                      # generated runner + our C plugin additions
  mirror_texture_plugin.cc  # GStreamer -> FlTexture bridge
sidecar/
  usb_inputd.py             # pymobiledevice3 shim (optional component)
```

## Packages

| Package | Use |
|---|---|
| `dbus` | BlueZ LEAdvertisingManager1, GattManager1, AgentManager1, Adapter1, Device1 |
| `shared_preferences` | settings |
| `window_manager` or none | window min size, close behavior |
| `process` (stdlib Process) | uxplay spawn/monitor |

Keep deps minimal. No riverpod/bloc for v1: plain `ChangeNotifier` services
plus `Stream`s from backends is enough for one screen of real UI.

## Method channels

`mirror/video` (implemented in the C plugin):

- `start(int port) -> int textureId`
- `stop()`
- `dimensions -> {width, height}` event channel for caps changes

`mirror/receiver` could be pure Dart (Process), keep it in Dart.

## Input routing

`InputRouter` owns the active `InputBackend`:

- selection order: USB if sidecar reports `connected`, else BLE.
- pointer events on the video widget -> coordinate_map -> backend.
- keyboard: `Focus` + `HardwareKeyboard` on the video widget; while focused,
  translate `KeyEvent`s to HID usages. Printable text also accepts IME paste
  via a hidden `TextInput` connection for CJK and emoji (typed as clipboard
  paste, since HID is US-layout only).
- a `FocusNode` toggles "controlling" mode; Esc releases.

## The mirror widget

- `Texture(textureId)` inside `FittedBox`/custom `LayoutBuilder` doing
  BoxFit.contain math (must match the input mapping math exactly; both use
  `coordinate_map.dart`).
- Cursor overlay: `CustomPaint` drawing the mapped point, 1-frame delayed
  smoothing optional.
- Toolbar: backend-aware buttons (Home/AppSwitcher/Spotlight always for BLE;
  Lock/Volume shown only on USB), backend badge ("BLE cursor" / "USB touch"),
  stream stats (fps, resolution, latency estimate) in a debug drawer.
- Disconnect banner when backend state != connected, with the pairing
  instructions inline.

## Onboarding wizard (pairing_page)

Step cards with real detection:

1. "Receiver running": ReceiverManager state -> uxplay up, ports bound.
2. "iPhone can see this PC": advert registered; hint to open Screen Mirroring.
3. "Video arriving": texture frames counter > 0.
4. "Input paired": GATT subscribed; shows AssistiveTouch steps with a
   countdown and "still not seeing it?" diagnostics.
5. "Button mapping": shows the Customize Additional Buttons steps, asks user
   to press each toolbar button and confirm the action landed.

Each step is skippable; the page doubles as diagnostics.

## Platform notes

- Wayland and X11 both fine: everything renders inside our own window.
  (AirBridge's X11-only bezel trick is unnecessary; we own the window.)
- HiDPI: query `MediaQuery.devicePixelRatio`, scale coordinate math; video
  texture is already in pixels so only the mapping layer cares.
- Window min size ~ 420x800 (portrait phone + toolbar).
- Light/dark: follow system via `MediaQuery.platformBrightness`.

## Testing

- `coordinate_map.dart`: pure function, unit tests for pillarbox/letterbox/
  rotation cases.
- `hid_codes.dart` + report builders: golden byte tests against the validated
  AirBridge descriptor and report encodings.
- `ReceiverManager` argv builder: snapshot tests per settings combo.
- GATT tree: register against a real BlueZ in CI? No. Keep it thin, test on
  hardware via the self-test button; add a `bt mock` debug backend that
  swallows events for UI development without a phone.
