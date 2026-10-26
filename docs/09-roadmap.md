# Roadmap

## M0: skeleton (repo state)

- [x] Design docs
- [ ] Flutter project scaffold (`flutter create --platforms=linux`)
- [ ] CI: analyze + unit tests on push
- [ ] LICENSE, NOTICE, contribution basics

## M1: view-only mirror

Goal: phone shows up in Screen Mirroring, video renders in the app.

- [ ] `ReceiverManager`: spawn/monitor uxplay, argv from settings
- [ ] C plugin: GStreamer RTP loopback -> FlTexture (software decode first)
- [ ] Mirror page: texture widget, letterbox math, connect/disconnect states
- [ ] Diagnostics page v1 (deps, ports, avahi, gst elements)
- [ ] Hardware decode path + software fallback toggle

Exit: 1080p stream visible in-app on Fedora/GNOME Wayland, <150 ms latency.

## M2: BLE cursor control

Goal: taps and drags work wirelessly on a stock iPhone.

- [ ] Dart GATT server over dbus pkg: HID service, 4 reports, battery, DIS
- [ ] LE advert + pairing agent + adapter state management
- [ ] `BleHidBackend`: absolute pointer, relative mouse, scroll
- [ ] Coordinate mapping wired to the video widget
- [ ] Pairing wizard with live state (advertising/subscribed)

Exit: click/drag/scroll on the mirrored screen works end to end.

## M3: keyboard + system buttons

- [ ] Report ID 2 keyboard with iOS-compatible dwell timing
- [ ] Report ID 3 consumer + pointer buttons 2/3/4 for Home/AppSwitcher/Spotlight
- [ ] In-app toolbar, "controlling" focus mode, Esc to release
- [ ] Text entry incl. paste-via-keystrokes for non-US chars
- [ ] Button-mapping onboarding step

Exit: typing into iOS fields works; toolbar buttons map to system actions.

## M4: USB path

- [ ] `sidecar/usb_inputd.py` around pymobiledevice3
- [ ] `UsbInputBackend` socket client + capability flags
- [ ] Setup flow: trust check, Developer Mode detection, DDI mount status
- [ ] Real multitouch + hardware buttons in UI

Exit: USB-connected iPhone gets true touch, no AssistiveTouch needed.

## M5: polish + packaging

- [ ] Fedora COPR package, Arch PKGBUILD
- [ ] firewalld service file, desktop file, icons
- [ ] Optional `--receiver-only` headless mode + user unit
- [ ] Hardening pass: socket perms, log redaction, error paths
- [ ] Docs: user guide with screenshots

## Later / maybe

- Flatpak (bundle uxplay, BlueZ system-bus permission)
- uxplay `-ble` beacon broadcast from our adapter for proximity discovery
- HEVC video path on USB mode (`rtph265depay`)
- Zero-copy GL texture (`FlTextureGL` + glupload)
- Notifications via ANCS (needs dual-transport bond; tether has the recipe,
  big scope)
- PIN entry flow rendered in-app
- Windows port (uxplay-windows exists; BLE peripheral story on Windows is
  weaker, USB path would carry control)
