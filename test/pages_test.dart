import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/l10n/app_localizations.dart';
import 'package:mirada/pages/about_page.dart';
import 'package:mirada/pages/devices_page.dart';
import 'package:mirada/pages/mirror_page.dart';
import 'package:mirada/pages/settings_page.dart';
import 'package:mirada/utils/version.dart';
import 'package:mirada/services/mirror.dart';
import 'package:mirada/services/update_checker.dart';
import 'package:mirada/services/settings.dart';

import 'widget_test_helpers.dart';

Widget wrap(Widget child, {Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('MirrorPage', () {
    testWidgets('idle hint', (t) async {
      await t.pumpWidget(wrap(MirrorPage(mirror: fakeMirror(), receiverName: () => 'Mirada')));
      expect(find.text('Nothing mirrored yet'), findsOneWidget);
    });

    testWidgets('connecting state', (t) async {
      final m = MirrorController(ReceiverService(
        run: (e, a) async => ProcessResult(0, 0, '', ''),
        launcher: _GatedLauncher(),
        receiverName: () => 'Mirada',
      ));
      await t.pumpWidget(wrap(MirrorPage(mirror: m, receiverName: () => 'Mirada')));
      unawaitedFuture(m.connect(const Phone(id: '1', name: 'iPhone')));
      await t.pump();
      expect(find.text('Connecting...'), findsOneWidget);
      await t.pumpAndSettle();
    });

    testWidgets('waiting shows receiver name and disconnect works', (t) async {
      final m = fakeMirror();
      await m.connect(const Phone(id: '1', name: 'My iPhone'));
      await t.pumpWidget(wrap(MirrorPage(mirror: m, receiverName: () => 'Desk')));
      expect(find.text('My iPhone'), findsOneWidget);
      expect(find.textContaining('Desk'), findsWidgets);
      await t.tap(find.text('Disconnect'));
      await t.pump();
      expect(find.text('Nothing mirrored yet'), findsOneWidget);
    });

    testWidgets('error state shows install hint', (t) async {
      final m = fakeMirror(ok: false);
      await m.connect(const Phone(id: '1', name: 'iPhone'));
      await t.pumpWidget(wrap(MirrorPage(mirror: m, receiverName: () => 'Mirada')));
      expect(find.textContaining('uxplay'), findsWidgets);
    });
  });

  group('DevicesPage', () {
    testWidgets('empty state and scan', (t) async {
      final source = FakeSource();
      final d = DeviceDiscovery(source);
      await t.pumpWidget(wrap(DevicesPage(discovery: d, mirror: fakeMirror())));
      expect(find.text('No iPhones found yet'), findsOneWidget);
      await t.tap(find.text('Scan'));
      await t.pump();
      d.dispose();
      await source.controller.close();
    });

    testWidgets('device list connects on tap', (t) async {
      final source = FakeSource()
        ..seed = const [Phone(id: '1', name: 'Cal iPhone', paired: true)];
      final d = DeviceDiscovery(source);
      final m = fakeMirror();
      await t.pumpWidget(wrap(DevicesPage(discovery: d, mirror: m)));
      await d.scan();
      await t.pump();
      expect(find.text('Cal iPhone'), findsOneWidget);
      expect(find.text('Paired'), findsOneWidget);
      await t.tap(find.text('Cal iPhone'));
      await t.pump();
      expect(m.status, isNot(MirrorStatus.idle));
      await m.disconnect();
      d.dispose();
      await source.controller.close();
    });

    testWidgets('connected device shows check', (t) async {
      final source = FakeSource()
        ..seed = const [Phone(id: '1', name: 'Cal iPhone')];
      final d = DeviceDiscovery(source);
      final m = fakeMirror();
      await m.connect(const Phone(id: '1', name: 'Cal iPhone'));
      await t.pumpWidget(wrap(DevicesPage(discovery: d, mirror: m)));
      await d.scan();
      await t.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      await m.disconnect();
      d.dispose();
      await source.controller.close();
    });
  });

  group('SettingsPage', () {
    testWidgets('renders all controls and edits persist', (t) async {
      t.view.physicalSize = const Size(1200, 1100);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final s = await fakeSettings();
      await t.pumpWidget(wrap(SettingsPage(settings: s)));
      expect(find.text('Settings'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'My Desk');
      expect(s.receiverName, 'My Desk');
      await t.tap(find.byType(DropdownButtonFormField<String>));
      await t.pumpAndSettle();
      await t.tap(find.text('2560x1440').last);
      await t.pumpAndSettle();
      expect(s.resolution, '2560x1440');
      await t.tap(find.byType(DropdownButtonFormField<int>));
      await t.pumpAndSettle();
      await t.tap(find.text('120').last);
      await t.pumpAndSettle();
      expect(s.frameRate, 120);
      await t.tap(find.byType(SwitchListTile).at(0));
      expect(s.requirePin, isTrue);
      await t.tap(find.byType(SwitchListTile).at(1));
      expect(s.avSync, isTrue);
      await t.tap(find.byType(DropdownButtonFormField<AppThemeMode>));
      await t.pumpAndSettle();
      await t.tap(find.text('OLED').last);
      await t.pumpAndSettle();
      expect(s.themeMode.name, 'oled');
      await t.tap(find.byType(DropdownButtonFormField<AppLanguage>));
      await t.pumpAndSettle();
      await t.tap(find.text('简体中文').last);
      expect(s.language.name, 'zh');
    });
  });

  group('AboutPage', () {
    testWidgets('shows version and update states', (t) async {
      final checker = IdleUpdateChecker();
      await t.pumpWidget(wrap(AboutPage(checker: checker)));
      expect(find.text('Mirada'), findsWidgets);
      expect(find.textContaining('0.1.0'), findsOneWidget);
      await t.tap(find.text('Check for updates'));
      await t.pump();
      await t.pumpAndSettle();
      expect(find.text('You are up to date'), findsOneWidget);
      expect(find.text('Project page'), findsOneWidget);
      await t.tap(find.text('Licences'));
      await t.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('update available and failed states', (t) async {
      await t.pumpWidget(wrap(AboutPage(checker: _StaticChecker(
        const UpdateAvailable(Version(1, 0, 0), 'v1.0.0'),
      ))));
      await t.tap(find.text('Check for updates'));
      await t.pump();
      await t.pumpAndSettle();
      expect(find.textContaining('1.0.0'), findsWidgets);
      await t.pumpWidget(wrap(AboutPage(checker: _StaticChecker(const UpdateFailed()))));
      await t.tap(find.text('Check for updates'));
      await t.pump();
      await t.pumpAndSettle();
      expect(find.text('Update check failed'), findsOneWidget);
    });
  });
}

void unawaitedFuture(Future<void> f) {}

class _StaticChecker extends UpdateChecker {
  _StaticChecker(this._state);
  final UpdateState _state;

  @override
  Future<UpdateState> check() async {
    await Future.delayed(const Duration(milliseconds: 5));
    return _state;
  }
}

class _GatedLauncher implements ReceiverLauncher {
  final completer = Completer<ReceiverHandle>();

  @override
  Future<ReceiverHandle> start(List<String> args) => completer.future;
}
