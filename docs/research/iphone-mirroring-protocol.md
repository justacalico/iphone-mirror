# iPhone Mirroring (Apple) — feasibility notes

Reviewed against public research and the app's observable internals (bundle id
`com.apple.ScreenContinuity`).

## What the official path uses

- Discovery + control channel: AWDL (Apple Wireless Direct Link), keyed by
  iCloud-synced device identities.
- Video/audio: Apple's Low-Latency Wi-Fi (LLW) transport.
- Trust anchor: a per-Mac cryptographic identity whose private key lives in the
  Secure Enclave, recorded on the iPhone at first enablement (Apple Platform
  Security Guide). The iPhone stays locked during sessions.

Sources:
- https://aaronschlitt.de/threat-modelling-and-analyzing-iphone-mirroring/
- Apple Platform Security Guide, iPhone Mirroring section
- mirroir-mcp / iphone-mirror-mcp project docs (the app relays AirPlay + BLE)

## Verdict

Not reimplementable on Linux, and not for lack of effort: the trust anchor is
an Apple-ID-bound identity with Secure Enclave key protection and iCloud
end-to-end encrypted key sync. iOS will not accept a "mirroring peer" that is
not a Mac with that attested identity. AWDL itself has Linux research (seemoo-
lab/owl), but the identity layer is the wall, not the link layer.

## What we do instead

Mirada composes the two stock-iOS surfaces that require no Apple identity:

- AirPlay mirroring (UxPlay) for the screen — wireless.
- BLE HID + AssistiveTouch for input — wireless, no Developer Mode.

UX target mirrors the official flow: open the app, the receiver and Bluetooth
advert are already live, tap your phone in Devices, done. First-time setup is a
guided AssistiveTouch pairing; after that the bond persists.
