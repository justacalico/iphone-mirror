import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'GB'),
    Locale('ga'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mirada'**
  String get appTitle;

  /// No description provided for @navMirror.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get navMirror;

  /// No description provided for @navDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get navDevices;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @mirrorIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing mirrored yet'**
  String get mirrorIdleTitle;

  /// No description provided for @mirrorIdleHint.
  ///
  /// In en, this message translates to:
  /// **'Pick your iPhone in Devices, or choose this computer in Control Centre > Screen Mirroring on the phone.'**
  String get mirrorIdleHint;

  /// No description provided for @mirrorWaitingVideo.
  ///
  /// In en, this message translates to:
  /// **'Receiver is live. Open Control Centre > Screen Mirroring on your iPhone and choose \"{name}\".'**
  String mirrorWaitingVideo(Object name);

  /// No description provided for @mirrorConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get mirrorConnecting;

  /// No description provided for @mirrorMirroring.
  ///
  /// In en, this message translates to:
  /// **'Mirroring'**
  String get mirrorMirroring;

  /// No description provided for @mirrorDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get mirrorDisconnect;

  /// No description provided for @mirrorError.
  ///
  /// In en, this message translates to:
  /// **'Could not start the receiver: {reason}'**
  String mirrorError(Object reason);

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesTitle;

  /// No description provided for @devicesScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get devicesScan;

  /// No description provided for @devicesScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get devicesScanning;

  /// No description provided for @devicesNone.
  ///
  /// In en, this message translates to:
  /// **'No iPhones found yet'**
  String get devicesNone;

  /// No description provided for @devicesHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure your iPhone is unlocked, on the same WiFi network, and within Bluetooth range.'**
  String get devicesHint;

  /// No description provided for @devicesConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get devicesConnected;

  /// No description provided for @devicesPaired.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get devicesPaired;

  /// No description provided for @devicesTapConnect.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect'**
  String get devicesTapConnect;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsReceiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get settingsReceiverName;

  /// No description provided for @settingsReceiverNameHint.
  ///
  /// In en, this message translates to:
  /// **'Shown in Screen Mirroring on your iPhone'**
  String get settingsReceiverNameHint;

  /// No description provided for @settingsResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get settingsResolution;

  /// No description provided for @settingsFrameRate.
  ///
  /// In en, this message translates to:
  /// **'Frame rate cap'**
  String get settingsFrameRate;

  /// No description provided for @settingsPin.
  ///
  /// In en, this message translates to:
  /// **'Require a PIN'**
  String get settingsPin;

  /// No description provided for @settingsAvSync.
  ///
  /// In en, this message translates to:
  /// **'Audio/video sync'**
  String get settingsAvSync;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System (default)'**
  String get languageSystem;

  /// No description provided for @languageEnGB.
  ///
  /// In en, this message translates to:
  /// **'Traditional English'**
  String get languageEnGB;

  /// No description provided for @languageZh.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageZh;

  /// No description provided for @languageRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageGa.
  ///
  /// In en, this message translates to:
  /// **'Gaeilge'**
  String get languageGa;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System (default)'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeOled.
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get themeOled;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Use your iPhone from your Linux desktop.'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(Object version);

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get updateChecking;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available'**
  String updateAvailable(Object version);

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You are up to date'**
  String get updateUpToDate;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update check failed'**
  String get updateFailed;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get aboutLicenses;

  /// No description provided for @aboutProject.
  ///
  /// In en, this message translates to:
  /// **'Project page'**
  String get aboutProject;

  /// No description provided for @receiverUxplayMissing.
  ///
  /// In en, this message translates to:
  /// **'uxplay was not found. Install it to enable mirroring (see the project README).'**
  String get receiverUxplayMissing;

  /// No description provided for @windowTitleMinimize.
  ///
  /// In en, this message translates to:
  /// **'Minimise'**
  String get windowTitleMinimize;

  /// No description provided for @windowTitleMaximize.
  ///
  /// In en, this message translates to:
  /// **'Maximise'**
  String get windowTitleMaximize;

  /// No description provided for @windowTitleRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get windowTitleRestore;

  /// No description provided for @windowTitleClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get windowTitleClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ga', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ga':
      return AppLocalizationsGa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
