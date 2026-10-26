# iPhone Mirror for Linux

Mirror and control an iPhone from a Linux desktop. The phone shows up in
Control Center > Screen Mirroring like an Apple TV, the screen renders inside
the app window, and taps, typing, and hardware buttons go back over Bluetooth
or USB.

No app is required on the iPhone for wireless mode. USB mode needs Developer
Mode enabled once.

## Status

Design phase. No working code yet. See `docs/09-roadmap.md`.

## How it works

Short version: [UxPlay](https://github.com/FDH2/UxPlay) acts as the AirPlay
receiver and forwards the H.264 stream to the app over loopback RTP. The app
(a Flutter desktop app) decodes and renders it, and turns local input into HID
reports. Input reaches the phone one of two ways:

- **Bluetooth LE HID + AssistiveTouch** (wireless, stock iPhone): the PC
  advertises itself as a BLE mouse/keyboard. iOS pairs it under
  Settings > Accessibility > Touch > AssistiveTouch and moves a cursor.
- **USB + Developer Mode** (iOS 17+): a pymobiledevice3 sidecar opens the
  CoreDevice screen stream and injects real multitouch HID reports through
  RemoteXPC. Feels like a touchscreen, not a cursor.

Full details are in `docs/`.

## Docs

- `docs/00-overview.md` goals, non-goals, how it compares to Apple's iPhone Mirroring
- `docs/01-architecture.md` components, process model, IPC
- `docs/02-airplay-receiver.md` UxPlay integration, discovery, ports, pairing
- `docs/03-video-pipeline.md` RTP loopback, GStreamer decode, Flutter texture
- `docs/04-control-ble-hid.md` the AssistiveTouch input path
- `docs/05-control-usb.md` the pymobiledevice3 input path
- `docs/06-flutter-app.md` app layout, packages, platform channel
- `docs/07-security-privacy.md` pairing, encryption, threat model
- `docs/08-packaging.md` distro deps, flatpak, systemd, firewall
- `docs/09-roadmap.md` milestones
- `docs/research/upstream-projects.md` notes from reviewing related projects

## License

AGPL-3.0. Chosen deliberately: the AirPlay receiver this project builds on
(UxPlay/RPiPlay) is GPL-3.0, and mirror/control software is exactly the kind
of thing that should stay open even when run as a service.
