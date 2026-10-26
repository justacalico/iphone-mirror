# Security and privacy

## Threat model

The app is a LAN-local bridge between a phone the user owns and a PC the user
owns. The realistic adversaries are:

1. Another device on the same LAN connecting to the receiver (open AirPlay
   server accepts anyone on the network by default).
2. A nearby BLE device bonding to the HID peripheral while it is advertising.
3. Malware on the PC abusing the input channel (out of scope; if the PC is
   compromised the phone is already reachable through it).

Not in scope: attacks over the internet (nothing listens off-LAN), malicious
iPhones (the phone is the user's own device).

## AirPlay session security

- Pair-setup/verify is SRP-6a + Curve25519 inside uxplay; session traffic is
  AES-encrypted. We inherit it by using uxplay unmodified.
- Default posture: receiver visible to the whole LAN. Mitigations exposed in
  settings:
  - `-pin` mode (4-digit on-screen PIN per session).
  - Device ACL via `-allow <list>` / `-restrict`.
  - Receiver off when the app is closed (we spawn it, we kill it; no
    always-on service in default install).
- Persistent pair keys live in `$HOME/.uxplay.*`; treat as sensitive
  (0600, never logged).

## BLE HID bond security

- GATT characteristics are flagged encrypt-read/encrypt-write; iOS will not
  talk to the report map without bonding+encryption.
- The advert is only on-air while input mode is enabled. Pairing window is
  user-initiated, not ambient.
- Pairing agent: `NoInputNoOutput` for HID bonds. Any other pairing method
  (PIN, numeric comparison) routes to an explicit user dialog, never
  auto-confirmed.
- Adapter `Pairable`/`Discoverable` flags are snapshotted on start and
  restored on exit so we do not leave the PC pairable forever.
- Risk accepted knowingly: while advertising, any nearby iPhone could pair
  during the window. Window is short and user-driven; the pairing wizard
  tells the user to disable input pairing after success.

## USB path security

- Developer services require a trusted USB pairing ("Trust this computer")
  plus Developer Mode. Both are explicit user grants on the phone.
- The sidecar socket is `$XDG_RUNTIME_DIR/...sock`, mode 0600, same-UID only.
- RemoteXPC runs over the usbmuxd/RSD trust relationship; nothing new is
  exposed to the network.

## Local hardening

- All local sockets (usb-input.sock, future control socket) in
  `$XDG_RUNTIME_DIR` with 0600.
- Logs never contain pairing keys, report contents, or keystrokes. Debug mode
  logs event types and counts, not key values.
- Settings file may store a fixed AirPlay PIN; warn in UI that a fixed PIN
  weakens the "only people in the room" property.
- No analytics, no crash reporting, no update pings. Fully offline.

## Dependency trust

- uxplay: GPLv3, audited lineage (RPiPlay -> UxPlay), distro-packaged.
- pymobiledevice3: GPLv3, active, pinned major version in packaging.
- BlueZ: system daemon, system privilege boundary.
- Flutter plugin C code: the only network-adjacent code we write; it reads a
  loopback UDP port only, still fuzz-tested for malformed RTP via
  `gst-validate`-style corpora later.

## What we deliberately do not do

- No attempt to defeat FairPlay, SRP, or Apple ID checks. Everything rides on
  what iOS grants to a normal AirPlay receiver, an accessibility HID device,
  or a developer pairing.
- No credentials harvested, no Apple ID flows, no iCloud anything.
