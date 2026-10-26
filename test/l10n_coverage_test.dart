import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/l10n/app_localizations.dart';
import 'package:mirada/services/update_checker.dart';

List<String> allStrings(AppLocalizations l) => [
      l.appTitle, l.navMirror, l.navDevices, l.navSettings, l.navAbout,
      l.mirrorIdleTitle, l.mirrorIdleHint, l.mirrorWaitingVideo('X'),
      l.mirrorConnecting, l.mirrorMirroring, l.mirrorDisconnect,
      l.mirrorError('e'), l.devicesTitle, l.devicesScan, l.devicesScanning,
      l.devicesNone, l.devicesHint, l.devicesConnected, l.devicesPaired,
      l.devicesTapConnect, l.settingsTitle, l.settingsReceiverName,
      l.settingsReceiverNameHint, l.settingsResolution, l.settingsFrameRate,
      l.settingsPin, l.settingsAvSync, l.settingsLanguage, l.languageSystem,
      l.languageEnGB, l.languageZh, l.languageRu, l.languageGa, l.settingsTheme,
      l.themeSystem, l.themeLight, l.themeDark, l.themeOled, l.aboutTagline,
      l.aboutVersion('1'), l.checkUpdates, l.updateChecking, l.updateAvailable('2'),
      l.updateUpToDate, l.updateFailed, l.aboutLicenses, l.aboutProject,
      l.receiverUxplayMissing, l.windowTitleMinimize, l.windowTitleMaximize,
      l.windowTitleRestore, l.windowTitleClose,
    ];

void main() {
  testWidgets('every string resolves in every locale', (t) async {
    for (final locale in AppLocalizations.supportedLocales) {
      late AppLocalizations l;
      await t.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (c) {
          l = AppLocalizations.of(c);
          return const SizedBox();
        }),
      ));
      expect(allStrings(l), everyElement(isNotEmpty));
    }
    expect(AppLocalizations.supportedLocales, hasLength(5));
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    expect(AppLocalizations.delegate.isSupported(const Locale('de')), isFalse);
    expect(() => AppLocalizations.delegate.load(const Locale('de')), throwsFlutterError);
    final delegate = AppLocalizations.delegate;
    expect(delegate.shouldReload(delegate), isFalse);
    for (final locale in AppLocalizations.supportedLocales) {
      final loaded = await delegate.load(locale);
      expect(allStrings(loaded), everyElement(isNotEmpty));
    }
  });

  test('update state classes instantiate', () {
    expect(UpdateIdle(), isA<UpdateState>());
    expect(UpdateChecking(), isA<UpdateState>());
    expect(UpdateFailed(), isA<UpdateState>());
    expect(UpdateUpToDate(), isA<UpdateState>());
  });
}
