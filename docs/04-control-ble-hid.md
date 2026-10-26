# Control path: BLE HID + AssistiveTouch

## Mechanism

The PC advertises itself as a standard Bluetooth LE HID peripheral. The user
pairs it once on the iPhone under
Settings > Accessibility > Touch > AssistiveTouch > Devices > Bluetooth
Devices. From then on iOS treats every HID report as AssistiveTouch input: a
cursor on the phone screen, clicks as touches, scroll as swipe, plus a real
keyboard.

This is the only way to send input to a stock, non-jailbroken, wireless iPhone.
It is the same mechanism pcairplay/AirBridge proved works end to end (their
control daemon is the reference implementation; see research notes).

## Why AssistiveTouch and not normal Bluetooth input

iOS accepts Bluetooth keyboards and mice from third parties for AssistiveTouch,
Switch Control, and Full Keyboard Access. It does not accept a generic "remote
touchscreen" HID device: there is no public HID usage that maps to native
touch. The absolute pointer report gets as close as iOS allows: with
AssistiveTouch in "pointer always jumps" behavior, the cursor lands exactly
where the report says, which reads visually like a real tap.

## GATT server layout

Registered on BlueZ via `GattManager1.RegisterApplication`, exported through
`org.freedesktop.DBus.ObjectManager`. In Dart this is a tree of
`DBusObject`s implementing `org.bluez.GattService1`,
`GattCharacteristic1`, `GattDescriptor1`.

Services:

- `0x1812` HID Service
  - `0x2A4A` HID Information (read): `11 01 00 02`
  - `0x2A4B` Report Map (read, encrypt-read)
  - `0x2A4C` HID Control Point (write-without-response)
  - `0x2A4E` Protocol Mode (read + write-without-response)
  - `0x2A4D` Report, notify, x4: relative mouse (ID 1), keyboard (ID 2),
    consumer control (ID 3), absolute pointer (ID 4)
  - `0x2908` Report Reference descriptor under each Report
- `0x180F` Battery Service, `0x2A19` fixed at 100 (iOS shows a battery icon;
  some iOS versions behave better when it exists)
- `0x180A` Device Information: manufacturer name, PnP ID (USB VID 0x1D6B
  Linux Foundation, or a registered value)

Report characteristics require encrypted reads in the descriptor flags: iOS
will bond and encrypt before subscribing.

## Report map

Composite descriptor, 4 reports (direct from the AirBridge implementation,
which validated it against iOS 17/18):

- **ID 1, relative mouse**: 3-byte report: button bits (8 buttons), signed
  dx/dy, wheel, horizontal wheel. Used for touchpad-style fallback and scroll.
- **ID 2, keyboard**: standard boot keyboard: modifier byte, reserved, 6
  keycodes. Used for all text entry and shortcuts.
- **ID 3, consumer control**: 16-bit usage. iOS maps some of these to system
  actions.
- **ID 4, absolute pointer**: buttons (3 bits) + 16-bit X + 16-bit Y, range
  0..32767. This is the primary tap surface; it places the AssistiveTouch
  cursor directly on screen coordinates.

The full byte-for-byte descriptor is ~110 bytes and lives in the AirBridge
source (`control.py`, `REPORT_MAP`); copy it verbatim for v1 and keep a copy
in `docs/research/` for reference.

## Pairing flow (user-facing)

1. App powers the adapter (`Adapter1.Powered`), sets `Pairable` and
   `Discoverable`, registers the GATT app and an LE advert:
   local name `"<receiver> Input"`, service UUID `0x1812`, appearance
   `0x03C0` (generic HID), `IncludesTxPower`.
2. In-app wizard shows: "On your iPhone: Settings > Accessibility > Touch >
   AssistiveTouch > on > Devices > Bluetooth Devices > tap `<name>`".
3. iPhone bonds (JustWorks). BlueZ notifies the registered `Agent1`. Our agent
   auto-accepts NoInputNoOutput; anything requiring confirmation goes to a
   Flutter dialog.
4. iOS subscribes to the report characteristics -> `StartNotify` -> backend
   state goes `connected`, input events flow.
5. On exit, restore the adapter's previous `Pairable`/`Discoverable` flags.

The wizard must also teach "Customize Additional Buttons": iOS has no generic
Home HID usage, so Home/App Switcher/Spotlight are ordinary pointer buttons
that the user maps in AssistiveTouch settings
(Devices > <device> > Customize Additional Buttons: Button 2 -> Home,
Button 3 -> App Switcher, Button 4 -> Spotlight). One-time per pairing.

## Input translation

| Desktop event | HID output |
|---|---|
| Move over video widget | absolute report ID 4 with mapped coords |
| Left button down/up | report ID 4, bit 0 set/clear at current coords |
| Drag | button bit held while coords stream |
| Right click | report ID 1 button 2 (iOS: AssistiveTouch menu or mapped action) |
| Wheel | report ID 1 wheel axis; two-finger horizontal maps to home paging |
| KeyDown/KeyUp | report ID 2, boot keyboard layout |
| Paste text | report ID 2 typed char-by-char (see quirks) |
| Toolbar Home/AppSwitcher/Spotlight | pointer buttons 2/3/4 (user-mapped) |
| Media keys (optional) | report ID 3 consumer usages |

Modifier bits: bit0 Ctrl, bit1 Shift, bit2 Alt/Option, bit3 GUI/Command. iOS
uses Command for shortcuts (Cmd+C/V/A work in text fields).

## iOS quirks (validated by AirBridge, must be preserved)

- **Key dwell**: iOS ignores too-short key reports. Send: neutral report,
  ~25 ms, modifier report, ~35 ms, key report, hold ~110 ms (180 ms for
  Space), release in order. Total ~170 ms per character. This makes paste of
  long strings slow; document it, offer "type as keystrokes" vs paste-via-
  clipboard where possible.
- **Space is special**: Full Keyboard Access reserves unmodified Space for
  "activate". Emit Shift+Space for a literal space. Text fields accept it
  identically.
- **Full Keyboard Access** conflicts: if the user has FKA on, several keys are
  intercepted. UI hint: recommend keeping it off.
- **Descriptor changes need re-pairing**: iOS caches the report map per bond.
  Change the descriptor, tell users to Forget This Device and re-pair.
  Version the descriptor and bump the PnP ID version when it changes.
- **Bonds are sticky**: a HID bond persists; phone will connect on sight after
  first pairing. Do not advertise when not running or the phone keeps
  connecting for no benefit.
- **One pointer at a time**: report ID 4 is single-contact. No pinch, no
  two-finger gestures, no real multitouch. Scrolling is wheel events, which
  iOS interprets as flick-scroll. Document clearly: cursor control, not touch.

## Cursor UX inside the app

- Draw a small ring/dot at the mapped position inside the video widget so the
  user sees where the iOS cursor is (there is up to ~150 ms of drift between
  our pointer and iOS rendering it).
- Configurable pointer mode: absolute (default) vs relative touchpad.
- "Focus" affordance: while the pointer is over the video, capture the
  keyboard for the phone; clicking outside releases.

## BlueZ requirements

- BlueZ >= 5.66 recommended (GATT + LE advertiser stability). Runtime probe:
  check `org.bluez.LEAdvertisingManager1.SupportedInstances` > 0.
- Adapter must support peripheral role: most Intel/AX200, CSR8510, Raspberry
  Pi onboard do; some cheap USB dongles do not. Diagnostics reports
  `SupportedInstances`, `SupportedFeatures`, and the adapter name.
- Needs the system D-Bus. Flatpak: `--system-talk-name=org.bluez` plus
  `--talk-name=org.freedesktop.Flatpak` is NOT enough for the system bus;
  use `--socket=system-bus` or a permission store rule (doc 08).

## Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| Phone doesn't list the peripheral | advert not registered; adapter off; old BlueZ | diagnostics page with concrete check results |
| Pairs then immediately drops | GATT tree rejected (descriptor error) | self-test registers/unregisters at startup, logs error |
| Connected, no cursor | AssistiveTouch off, or iOS did not subscribe | status shows subscribed=false with phone-side instructions |
| Cursor offset | stale letterbox math after rotation | recalc on caps-change; offer manual calibration offset in settings |
| Keys land wrong | FKA on, or keyboard layout mismatch | US layout documented; FKA warning banner |
