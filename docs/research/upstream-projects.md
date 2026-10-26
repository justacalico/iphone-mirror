# Upstream project review notes

Reviewed 2026-10-26. What each project is, what it proves, what we take from
it.

## FDH2/UxPlay (GPLv3)

The AirPlay receiver engine. mDNS advert (`_airplay._tcp`, `_raop._tcp`),
RTSP, FairPlay handshake (`lib/playfair`, `fairplay_playfair.c`), SRP pairing
(`srp.c`, `pairing.c`), RAOP audio, mirror RTP video (`raop_rtp_mirror.c`),
GStreamer renderers.

Key findings:

- `-vrtp "<pipeline>"` forwards the video stream through `rtph26[4,5]pay` to
  an arbitrary sink, e.g. `udpsink host=127.0.0.1 port=5000`. This is the
  embed hook: we decode locally instead of embedding their renderer.
- `-artp` does the same for audio (rtpL16pay).
- `-p 7000` fixes ports for firewalls; `-pin`/`-reg` for pairing;
  `-allow`/`-block`/`-restrict` ACLs; `-avdec` software decode.
- `-h265` must be OFF on the -vrtp path: RTP carries no codec hint, a fixed
  depayloader cannot switch mid-stream.
- `-ble <file>` writes Apple-format BLE beacon data for an external
  broadcaster (`Bluetooth_LE_beacon/uxplay-beacon.py`, has a BlueZ backend):
  AppleTV-style proximity discovery without mDNS.
- Renders video via `appsrc` into a parsed pipeline; audio renderer is
  independent, so we can leave audio to uxplay in v1.

Take: use as managed subprocess, argv contract documented in doc 02.

## gbulog/pcairplay (MIT)

Windows + Arch desktop wrapper around uxplay. Installers, firewall, firewall
doctor, GTK4 UI, and the original Linux control work (PR #1 by Nolan Cotter)
that AirBridge took over. Its README documents the real user-facing behavior:

- Phone sees PC in Screen Mirroring like an Apple TV, nothing installed on
  iOS.
- Control = BLE HID peripheral + iOS AssistiveTouch; pairing path is
  Settings > Accessibility > Touch > AssistiveTouch > Devices.
- Home/AppSwitcher/Spotlight are ordinary HID pointer buttons remapped in
  AssistiveTouch > Customize Additional Buttons. iOS accepts no generic Home
  command.
- Fixed ports 7000-7002 + 5353 chosen to avoid firewall pain.
- X11-only window tricks (wmctrl bezel) are irrelevant to us on Wayland since
  we own the window.

## NolanCotter/AirBridge (MIT)

The proof-of-concept this design is built on. `airbridge/control.py` is the
reference for the whole BLE path:

- Composite HID report map: ID 1 relative mouse, ID 2 boot keyboard, ID 3
  consumer, ID 4 absolute pointer (0..32767 X/Y). Copy verbatim.
- GATT tree via `bluez-peripheral` (HID 0x1812 + Battery 0x180F + DIS 0x180A),
  LE advert with appearance 0x03C0, service UUID 0x1812.
- JSON-lines unix-socket IPC for input events: shape reused for our USB
  sidecar protocol.
- iOS quirks documented in code: key dwell ~110 ms (180 ms Space), modifier
  ordering, Shift+Space for literal space under Full Keyboard Access, forget+
  re-pair after descriptor changes, chunked relative moves over 127.
- Embedded mode: uxplay `-vrtp` to localhost + GTK decodes with its own
  GStreamer pipeline. Exactly our plan with Flutter texture instead of
  GtkImage/Gst paintable.

Status: early (2 commits, stub README) but the substance is all in
control.py and works as described by pcairplay's verified README.

## zackb/tether (MIT, 1.5k stars)

Different problem (Continuity features, not mirroring): messages via MAP,
contacts via PBAP, notifications via ANCS, calls via HFP, clipboard/files via
their own iOS app. Worth its docs for Bluetooth hard-won lessons:

- `docs/BLUETOOTH.md`: BlueZ experimental bearer requirements, Class of
  Device effects, connect-first vs explicit-pair bond strategies,
  cross-transport bond semantics (BR/EDR-only bond can never carry ANCS),
  pairing agent behavior, failure table.
- Shows the level of BlueZ weirdness to expect; our HID peripheral story is
  simpler because we are the peripheral and iOS is the central, but the
  agent + bearer notes still apply.

Take: cite in security/packaging docs; future ANCS feature would follow
their recipe (needs the dual-transport bond they document).

## doronz88/pymobiledevice3 (GPLv3)

The USB control substrate for iOS 17+:

- In-process rootless RSD tunnels now; `mounter auto-mount` handles DDI
  (PersonalizedDMG 17-26.x, Cryptex1 27+).
- CoreDevice screen stream: HEVC/RTP video + AAC-ELD audio.
- HID: `com.apple.coredevice.hid.universalhidservice` +
  `com.apple.coredevice.hid.indigo`; 58-byte touchscreen reports (ID 0x09,
  coords 0..65535), keyboard bitmap report (ID 0x01), hardware buttons via
  IndigoHIDService.send_button (Consumer page).
- HID gated on an active media stream session.
- Ships a VNC server wrapper already; we wrap a slimmer JSON-lines sidecar.

Take: sidecar, not a dependency in the process; protocol mirrors the
AirBridge socket vocabulary.

## Also evaluated

- `FD-/RPiPlay`: UxPlay's ancestor, superseded; kept for reference on
  renderer internals.
- `huisinro/ios-usb-mirroring`: old QuickTime usbmux screen protocol
  (iOS <17 era, display only); superseded by the CoreDevice path. Not used.
- `xphoneuse.com`: closed-source proof the USB path ships as a real product.
- `rclinux/iphone-link`, `gabrielmeir53/iphonebridge`: file/message sync
  wrappers around libimobiledevice + uxplay + BT profiles. Useful prior art
  for integration UX, not for protocol details.
