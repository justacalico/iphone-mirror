# Packaging and system integration

## Runtime dependencies

| Dep | Why | Fedora | Debian/Ubuntu | Arch |
|---|---|---|---|---|
| uxplay >= 1.66 | receiver engine | `uxplay` | `uxplay` | `uxplay` (AUR) |
| GStreamer core | decode | `gstreamer1-plugins-base` | `gstreamer1.0-plugins-base` | `gst-plugins-base` |
| RTP/H264 | stream | `gstreamer1-plugins-good`, `gstreamer1-plugins-bad-free`, `gstreamer1-libav` | `gstreamer1.0-plugins-good`, `-bad`, `libav` | `gst-plugins-good`, `-bad`, `-libav` |
| avahi | mDNS | `avahi` | `avahi-daemon` | `avahi` |
| bluez >= 5.66 | BLE peripheral | `bluez` | `bluez` | `bluez` |
| python + pymobiledevice3 | USB path (optional) | `python3-pymobiledevice3` or pipx | pipx | `python-pymobiledevice3` |
| flutter | build-time | toolbox/manual | manual | `flutter` (AUR) |

## Firewall

Ship a firewalld service file `iphone-mirror.xml` (ports 7000-7002 tcp+udp,
plus 5353/udp normally covered by the mdns service). Install to
`/usr/lib/firewalld/services/`. For ufw/nftables users, document the rules in
the diagnostics page rather than scripting them silently.

## systemd

Optional user unit `iphone-mirror.service` for "receiver always on" mode.
Not enabled by default. Uses `ExecStart=/usr/bin/iphone-mirror --receiver-only`
(a headless mode that runs uxplay without opening a window).

## Desktop integration

- `.desktop` file + icons per fd.o spec.
- App ID: `dev.httpanimations.iphone_mirror`.
- XDG dirs: config `~/.config/iphone-mirror/`, state/logs
  `~/.local/state/iphone-mirror/`, cache `~/.cache/iphone-mirror/`.

## Flatpak

Flutter desktop + flatpak is workable but has two friction points:

1. BlueZ: needs `--system-talk-name=org.bluez` for the GATT/advert/agent APIs
   plus read access to adapter props. Grant via manifest; document that
   `--socket=system-bus` is the fallback if granular names fail.
2. uxplay inside flatpak: either bundle it (build in the manifest) or spawn
   the host's uxplay via `flatpak-spawn --host`. Bundling is simpler and
   version-pinned; choose bundling for v1 flatpak.

Flatpak is a v1.x goal, not v0.1. Native packages first since they are what
the maintainer's machine (Fedora) runs.

## Native packages

- **Fedora**: COPR. Spec bundles the Flutter release build (linux-x64 bundle)
  + plugin .so + sidecar. `Requires: uxplay, gstreamer1-plugins-*`.
- **Arch**: PKGBUILD in `packaging/arch/`, `depends=(uxplay gst-plugins-*)`.
- **Debian/Ubuntu**: deb via `dpkg-deb` in CI; same file layout under
  `/usr/lib/iphone-mirror/` + `/usr/bin/iphone-mirror` launcher.

## Diagnostics (ships in the app)

A "Diagnostics" page that checks, in order, and prints the exact fix:

- bluetooth.service running, adapter present, `SupportedInstances` > 0
- avahi-daemon running
- uxplay found + version >= floor
- gst-inspect for: udpsrc, rtpjitterbuffer, rtph264depay, avdec_h264,
  a hw decoder, appsink
- firewall state for 5353/7000-7002 (best-effort probe)
- iPhone-visible self-test: register the advert for 10 s and report
  whether it took

## Versioning

SemVer on the app. The BLE report-map descriptor gets its own version
(`descriptorVersion` in settings) because iOS caches it per bond; bumping it
triggers a "re-pair your input device" notice.
