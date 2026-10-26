# Mirada

**Use your iPhone from your Linux desktop.**

Mirada puts your iPhone's screen in a window on Linux and sends your clicks,
drags and typing back over Bluetooth. The phone sees the PC in Control Centre >
Screen Mirroring, exactly like an Apple TV. No jailbreak, no sideloading, no app
on the phone, no account.

[![pipeline](https://gitlab.com/HttpAnimations/iphone-mirror/badges/main/pipeline.svg)](https://gitlab.com/HttpAnimations/iphone-mirror/-/pipelines)
[![release](https://gitlab.com/HttpAnimations/iphone-mirror/-/badges/release.svg)](https://gitlab.com/HttpAnimations/iphone-mirror/-/releases)
[![license](https://img.shields.io/gitlab/license/HttpAnimations/iphone-mirror)](https://gitlab.com/HttpAnimations/iphone-mirror/-/blob/main/LICENSE)
[![pages](https://img.shields.io/badge/site-landing-blue)](https://httpanimations.gitlab.io/iphone-mirror/)

**[Landing page + downloads](https://httpanimations.gitlab.io/iphone-mirror/)**

## What you get

- The iPhone's screen live in a native window, over WiFi.
- Clicks, drags, scrolling, and keyboard input back to the phone over Bluetooth.
- A one-time guided pairing: everything after that is open-the-app, tap the
  phone, done.
- Dark, light, OLED and system themes; English, 简体中文, Русский and Gaeilge UI.
- An in-app update checker wired to the release feed.

## Install

```sh
curl -fLO https://httpanimations.gitlab.io/iphone-mirror/flatpak/key.gpg
flatpak remote-add --if-not-exists --gpg-import=key.gpg mirada https://httpanimations.gitlab.io/iphone-mirror/flatpak
flatpak install mirada gitlab.httpanimations.mirada
```

or one command:

```sh
flatpak install https://httpanimations.gitlab.io/iphone-mirror/mirada.flatpakref
```

.deb, .rpm, AppImage and zip builds for x86_64 and aarch64 live on the
[releases page](https://gitlab.com/HttpAnimations/iphone-mirror/-/releases).

## How it works

The receiver is [UxPlay](https://github.com/FDH2/UxPlay), the same AirPlay
server every third-party mirror tool uses. Input goes back through a Bluetooth
LE HID device the app advertises; iOS accepts it through AssistiveTouch. Pairing
once is guided inside the app; afterwards the bond persists and control is
instant.

## Screenshots

![Mirror](https://gitlab.com/HttpAnimations/iphone-mirror/-/raw/main/test/goldens/mirror_idle.png)
![Settings](https://gitlab.com/HttpAnimations/iphone-mirror/-/raw/main/test/goldens/settings.png)

## License

[AGPL-3.0](https://gitlab.com/HttpAnimations/iphone-mirror/-/blob/main/LICENSE)
