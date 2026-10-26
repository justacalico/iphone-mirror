# Overview

## What this is

A Linux app that gives an iPhone the two things Apple's iPhone Mirroring gives a
Mac:

1. The phone's screen in a desktop window, live, with audio.
2. Input going back: taps, drags, scrolling, typing, Home, App Switcher.

Apple's version also adds iPhone notifications on the desktop and drag and drop
file transfer. Those are explicitly out of scope for v1 and listed under future
work.

## What Apple's version does (and why we are not cloning it)

Apple iPhone Mirroring (macOS 15 + iOS 18) uses:

- Proximity and same-Apple-ID checks over BLE and the local network.
- An AirPlay-derived encrypted session, with the phone kept locked.
- Continuity plumbing for input that Apple does not expose to third parties.

The pairing and trust anchor (Apple ID, iCloud keychain, secure enclave
attestation) cannot be reimplemented on Linux. iOS does not offer that trust
relationship to anything that is not signed by Apple. So this project does not
try to clone the protocol. It composes two documented, iOS-supported surfaces:

- **AirPlay mirroring**, which every iPhone supports for sending its screen to
  an Apple TV or compatible receiver.
- **HID input**, which iOS accepts either through AssistiveTouch over BLE
  (accessibility feature, works on any stock phone) or through the developer
  HID services over USB (Developer Mode).

The result is not as seamless as Apple's. Pairing is per-feature instead of
per-Apple-ID, and the wireless path moves a cursor rather than injecting real
touches. The tradeoffs of each path are spelled out in docs 04 and 05.

## Goals

- View-only mirroring works with one command and zero phone setup beyond
  picking the PC in Screen Mirroring.
- Full control works on a stock, non-jailbroken iPhone over WiFi + Bluetooth.
- A higher-fidelity USB path exists for people who can enable Developer Mode.
- The whole thing runs on Wayland and X11, on ordinary distros, packaged
  normally (rpm/deb/flatpak/AUR).
- Every external component is swappable: receiver, transport, input backend.

## Non-goals

- No port of Apple's proprietary Continuity protocol.
- No support for jailbroken devices. Everything works on stock iOS.
- No Android support. scrcpy already exists and is better than anything this
  project could do there.
- No cloud service, accounts, or telemetry. Everything is LAN-local.
- Not an AirPlay sender, second-display solution, or file transfer tool.

## Success criteria for v1

- Phone discovers the PC in Control Center > Screen Mirroring.
- Stream starts and stays stable at 1080p, 30 to 60 fps.
- Pointer input maps to the correct on-screen location within a few pixels.
- Typing Latin text into an iOS text field works.
- Setup instructions on the phone are presented in-app, not in a wiki.

## Naming

Working title is "iPhone Mirror for Linux". The repo is `iphone-mirror`. If
the name ever needs to change (trademark politeness), the identifier is
`dev.httpanimations.iphone_mirror` internally and only the display name moves.
