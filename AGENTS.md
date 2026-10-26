# Mirada

Mirada mirrors an iPhone screen to a Linux desktop and sends input back over
Bluetooth HID + AssistiveTouch. Stock iOS only: no jailbreak, no app on the
phone, no Developer Mode.

- Flutter app at repo root; landing page (Flutter web) in `landing/`.
- Every change needs tests. Coverage must stay at 100% (`flutter test --coverage`).
- Goldens live in `test/goldens/`; regenerate with `flutter test --update-goldens`.
- Refactor rather than duplicating. Keep modules small; no god files.
- Conventional commits only (`feat:`, `fix:`, `chore:`...) so cocogitto can bump versions.
- Aim for an A+ codebase.
