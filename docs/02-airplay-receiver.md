# AirPlay receiver (UxPlay)

## Role

UxPlay implements the server half of AirPlay mirroring: mDNS advertisement,
RTSP control channel, FairPlay key exchange, SRP pair-setup/pair-verify, the
RAOP service, and the mirror RTP stream. The iPhone finds it in
Control Center > Screen Mirroring exactly like an Apple TV. No iOS-side
software.

Upstream: https://github.com/FDH2/UxPlay (GPLv3). Descended from FD-/RPiPlay.

## Launch contract

`ReceiverManager` builds argv from settings. Baseline for embedded mode:

```
uxplay \
  -n "<receiver name>" \
  -nh \                       # no hostname suffix in the AirPlay name
  -s 1920x1080@60 \           # advertised resolution + refresh
  -fps 60 \                   # frame rate cap reported to the client
  -nc \                       # do not close window on disconnect
  -nohold \                   # drop stale client state immediately
  -p 7000 \                   # fixed base port (firewall friendly)
  -vrtp "config-interval=1 pt=96 ! udpsink host=127.0.0.1 port=$VPORT" \
  -vs 0                       # no local video sink; app renders
```

Notes on specific flags:

- `-vrtp <pipeline>` makes uxplay append the given elements after an implicit
  `rtph264pay`/`rtph265pay` and send the stream there instead of rendering it.
  This is the whole embedding trick: the app picks up a normal RTP/H.264 UDP
  stream on loopback and decodes it itself. Verified working in AirBridge.
- **Force H.264, not H.265, on this path.** UxPlay advertises both when `-h265`
  is passed. The RTP stream carries no codec metadata, so a fixed local
  `udpsrc ! rtph264depay` pipeline cannot handle a mid-stream codec choice.
  Embedded mode deliberately omits `-h265`. H.264 at 1080p60 is what every
  iPhone sends anyway.
- `-s WxH@RR` is only the advertised mode. The iPhone sends its own aspect;
  letterboxing is handled on our side (03).
- Leave `-vsync`/`-async` at defaults initially; expose an "A/V sync" toggle
  that maps to `-vsync` for users who notice lip-sync drift.

### Full argv matrix

| Setting | Flag | Default |
|---|---|---|
| Receiver name | `-n`, `-nh` | hostname |
| Resolution/refresh | `-s WxH@RR` | 1920x1080@60 |
| FPS cap | `-fps n` | 30 -> 60 |
| Fixed ports | `-p 7000` | on; `-p` alone = legacy dynamic |
| PIN | `-pin [code] -reg` | off |
| Client ACL | `-allow`/`-block`/`-restrict` | off |
| Software decode | `-avdec` | off (hw accel tried first) |
| Video forward | `-vrtp "<pipeline>"` | embedded mode only |
| Audio forward | `-artp "<pipeline>"` | not used in v1 |
| BLE beacon data | `-ble [file]` | off; see discovery section |
| Debug | `-d 1` | off |

## Discovery

Two mechanisms, both supported:

### mDNS (primary)

UxPlay registers `_airplay._tcp` and `_raop._tcp` via avahi-daemon
(`libdns_sd`) or its bundled `mdnsd`. Requirements:

- avahi-daemon running (default on Fedora/GNOME, Debian, Ubuntu).
- UDP 5353 reachable (mDNS).
- Same L2 broadcast domain as the iPhone, or an mDNS reflector. Guest WiFi and
  many corporate VLANs break this; that is a documented limitation, not a bug.

### BLE beacon (secondary, for proximity discovery)

UxPlay's `-ble <file>` flag writes the Apple-format beacon payload to a file;
`uxplay_beacon` (shipped in UxPlay's `Bluetooth_LE_beacon/`, has a BlueZ
backend) broadcasts it as an LE advertisement. This is how a real Apple TV
gets discovered even when mDNS is filtered, and it produces the
"your iPhone is nearby" UX.

Our app already runs a BLE peripheral for input (doc 04). Broadcasting the
beacon from the same adapter is a v2 feature: one advertiser, alternating or
combined advert sets. The doc 04 service uses a normal connectable advert; the
beacon is non-connectable. BlueZ supports multiple LE advertisements on one
adapter (adapter-dependent, most Intel/CSR chips handle 2+).

## Ports and firewall

Fixed-port mode (`-p 7000`) uses:

| Port | Proto | Purpose |
|---|---|---|
| 5353/udp | mDNS | discovery (avahi) |
| 7000/tcp+udp | AirPlay | RTSP control + mirror |
| 7001/tcp+udp | AirPlay | mirror data + timing |
| 7002/tcp | AirPlay | audio (RAOP) |

Packaging opens these via firewalld service file (`/usr/lib/firewalld/services/`)
or documented ufw/nftables rules. Loopback RTP port (default 5000, allocated
dynamically) needs no firewall rule.

## Pairing and access control

- AirPlay pair-setup/pair-verify is SRP-6a + Curve25519, handled inside uxplay.
  Bonds persist in `$HOME/.uxplay.*` key files (`-key <file>` to relocate).
- Optional PIN (`-pin` shows a 4-digit code on screen; `-pin 4321` fixed;
  `-reg` registers the pairing). The app needs to render the PIN itself in
  embedded mode, since uxplay's PIN overlay lives in its own video sink. Plan:
  intercept via `-vdmp` metadata file or surface uxplay's own window for the
  PIN step in v1, revisit later.
- `-allow`/`-block`/`-restrict` give a device ACL by MAC/name. Expose as a
  simple "only these devices" list in settings.

## Audio decision (v1)

UxPlay renders audio through its own GStreamer audiosink (`-as`). In embedded
mode we still let it: the video RTP forward is video-only, and uxplay keeps
audio synced against its NTP clock, which is more correct than anything we can
bolt on in v1. `-artp` forwarding exists for v2 if we want a volume slider or
mute button inside our window.

## Health monitoring

- Parse uxplay stdout for lifecycle lines; `-d 1` gives verbose logs into a
  rotating file under `$XDG_STATE_HOME/iphone-mirror/logs/`.
- Watchdog: child exit -> classify. Port-in-use and missing-GStreamer-plugin
  are the two common failures; both get specific UI text.
- `-reset <n>` recovers from dead-client state if a phone disappears mid-stream.

## Version floor

Require uxplay >= 1.66 (stable `-vrtp`, AirPlay2 "legacy pairing" support,
Fedora packages start there). Detect with `uxplay -h` and parse the version
banner at first run; warn below floor.
