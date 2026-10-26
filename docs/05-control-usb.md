# Control path: USB via pymobiledevice3 (iOS 17+)

## Why this path exists

The BLE path gives cursor-class control on stock phones. The developer
services on iOS give the real thing: multi-contact touch injection, hardware
buttons, and a native screen stream, at the cost of a cable and Developer
Mode. This is the same stack pymobiledevice3 ships as its screen-streaming /
remote-display feature, and the same one tools like XPhoneUse wrap.

## Requirements

- iOS 17.0 or newer (CoreDevice/RemoteXPC era).
- USB connection (or an established RSD tunnel; tunnel over WiFi pairing is
  possible but USB is the reliable path).
- **Developer Mode enabled on the iPhone**: Settings > Privacy & Security >
  Developer Mode. Enabling it reboots the phone once and shows a warning.
  pymobiledevice3 can enable it: `pymobiledevice3 amfi enable-developer-mode`.
- **DeveloperDiskImage (DDI) mounted**: `pymobiledevice3 mounter auto-mount`
  picks per iOS version (PersonalizedDMG for 17.x-26.x, Cryptex1 for 27+).
  Images download and cache under `~/.pymobiledevice3`.
- Device trusted (USB pairing, "Trust this computer" once).

## The moving parts

| Piece | What it is |
|---|---|
| RSD tunnel | RemoteXPC channel to `com.apple.internal.dt` services. pymobiledevice3 establishes an in-process, rootless tunnel (modern versions; older needed `sudo pymobiledevice3 remote start-tunnel`). |
| Screen stream | `com.apple.coredevice` display service: HEVC (H.265) over RTP for video, AAC-ELD for audio. Higher quality and lower latency than the AirPlay path. |
| HID services | `com.apple.coredevice.hid.universalhidservice` and `com.apple.coredevice.hid.indigo` over RemoteXPC. |
| Media-stream gate | iOS ignores HID reports unless a media stream session is active (`action.mediastreamstart`). The stream and the input channel are a pair, not independent features. |

## Report formats (from pymobiledevice3 internals)

- **Touch**: 58-byte report, report ID `0x09` (TOUCHSCREEN), target
  `DIGITIZER_SURFACE_MAIN_TOUCHSCREEN` (ServiceID 257). Coordinates normalized
  to 0..65535 in both axes. Supports real multi-contact state.
- **Keyboard**: report ID `0x01`, 240-bit usage bitmap covering HID page 0x07.
  No key-dwell timing hacks needed, reports are state updates.
- **Hardware buttons**: `IndigoHIDService.send_button` with Consumer page
  (0x0C) usages: Home, Lock, Volume up/down, etc. These are the actual
  physical buttons, not AssistiveTouch pointer-button remaps. No per-user
  button mapping needed.

## What this buys over BLE

- Real taps and real multitouch (pinch, multi-finger gestures where the HID
  digitizer allows).
- No AssistiveTouch setup, no on-screen cursor overlay, no per-user button
  mapping.
- True hardware buttons including Lock and volume.
- H.265 stream option: better quality per bit, and this path carries its own
  codec metadata so HEVC is safe (unlike the AirPlay -vrtp forward).
- Works when WiFi is hostile: the whole session runs over USB.

## What it costs

- Cable (or RSD tunnel).
- Developer Mode: one reboot, and an enterprise-admin-visible setting that
  some managed devices cannot enable (MDM can block it).
- Python + pymobiledevice3 on the host. Versioned dependency to track; its
  CLI and APIs move quickly.
- iOS version matrix risk: PersonalizedDMG is bound to chip/build manifest;
  brand-new iPhones sometimes land outside a DDI's supported list until Apple
  updates it.

## Sidecar design

We do not link pymobiledevice3 (GPLv3, Python). We spawn a sidecar:

```
sidecar/usb_inputd.py        # ~200 lines, our code
  - starts pymobiledevice3 tunnel + screen stream
  - listens on $XDG_RUNTIME_DIR/iphone-mirror/usb-input.sock
  - JSON-lines in, same vocabulary as the BLE backend
```

The Dart `UsbInputBackend` is a socket client implementing the same
`InputBackend` interface; UI cannot tell the difference. Capabilities are
reported by the backend (`supportsMultitouch`, `supportsHardwareButtons`,
`trueTouch`), so the toolbar can enable gestures only when meaningful.

Video: two options.

- v1 keeps the AirPlay video path even in USB mode (control over USB, video
  over WiFi). Weird but works, minimal new code.
- v2 decodes the CoreDevice HEVC stream in-process; pymobiledevice3 can emit
  the RTP stream to a local UDP port, same appsink pattern as doc 03 with
  `rtph265depay` + HEVC decoder.

## Failure modes

- Developer Mode off: sidecar exits with a clear error, UI offers the
  Settings path (and can offer to run the enable command, warning that the
  phone will reboot).
- DDI mount fails / no build identity for device: sidecar reports the
  pymobiledevice3 error verbatim with a link to known-issues.
- Tunnel drops: backend -> `disconnected`, auto-reconnect with backoff while
  the cable stays plugged.
- Phone locked: most developer services require an unlocked device; UI shows
  "unlock your iPhone" state.
