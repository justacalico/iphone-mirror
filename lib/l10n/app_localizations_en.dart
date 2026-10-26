// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mirada';

  @override
  String get navMirror => 'Mirror';

  @override
  String get navDevices => 'Devices';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAbout => 'About';

  @override
  String get mirrorIdleTitle => 'Nothing mirrored yet';

  @override
  String get mirrorIdleHint =>
      'Pick your iPhone in Devices, or choose this computer in Control Centre > Screen Mirroring on the phone.';

  @override
  String mirrorWaitingVideo(Object name) {
    return 'Receiver is live. Open Control Centre > Screen Mirroring on your iPhone and choose \"$name\".';
  }

  @override
  String get mirrorConnecting => 'Connecting...';

  @override
  String get mirrorMirroring => 'Mirroring';

  @override
  String get mirrorDisconnect => 'Disconnect';

  @override
  String mirrorError(Object reason) {
    return 'Could not start the receiver: $reason';
  }

  @override
  String get devicesTitle => 'Devices';

  @override
  String get devicesScan => 'Scan';

  @override
  String get devicesScanning => 'Scanning...';

  @override
  String get devicesNone => 'No iPhones found yet';

  @override
  String get devicesHint =>
      'Make sure your iPhone is unlocked, on the same WiFi network, and within Bluetooth range.';

  @override
  String get devicesConnected => 'Connected';

  @override
  String get devicesPaired => 'Paired';

  @override
  String get devicesTapConnect => 'Tap to connect';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsReceiverName => 'Receiver name';

  @override
  String get settingsReceiverNameHint =>
      'Shown in Screen Mirroring on your iPhone';

  @override
  String get settingsResolution => 'Resolution';

  @override
  String get settingsFrameRate => 'Frame rate cap';

  @override
  String get settingsPin => 'Require a PIN';

  @override
  String get settingsAvSync => 'Audio/video sync';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System (default)';

  @override
  String get languageEnGB => 'Traditional English';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageGa => 'Gaeilge';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System (default)';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED';

  @override
  String get aboutTagline => 'Use your iPhone from your Linux desktop.';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get updateChecking => 'Checking for updates...';

  @override
  String updateAvailable(Object version) {
    return 'Version $version is available';
  }

  @override
  String get updateUpToDate => 'You are up to date';

  @override
  String get updateFailed => 'Update check failed';

  @override
  String get aboutLicenses => 'Licences';

  @override
  String get aboutProject => 'Project page';

  @override
  String get receiverUxplayMissing =>
      'uxplay was not found. Install it to enable mirroring (see the project README).';

  @override
  String get windowTitleMinimize => 'Minimise';

  @override
  String get windowTitleMaximize => 'Maximise';

  @override
  String get windowTitleRestore => 'Restore';

  @override
  String get windowTitleClose => 'Close';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');
}
