import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/app.dart';
import 'package:mirada/l10n/app_localizations.dart';
import 'package:mirada/pages/about_page.dart';
import 'package:mirada/pages/devices_page.dart';
import 'package:mirada/pages/mirror_page.dart';
import 'package:mirada/pages/settings_page.dart';
import 'package:mirada/services/mirror.dart';
import 'package:mirada/theme.dart';

import 'widget_test_helpers.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Inter')
    ..addFont(File('assets/fonts/Inter.ttf').readAsBytes().then(
          (b) => b.buffer.asByteData(b.offsetInBytes, b.lengthInBytes),
        ));
  await loader.load();
}

Widget wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? lightTheme(),
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

Future<void> snap(WidgetTester t, Widget w, String name) async {
  await t.binding.setSurfaceSize(const Size(1000, 700));
  t.view.physicalSize = const Size(1000, 700);
  t.view.devicePixelRatio = 1.0;
  await t.pumpWidget(w);
  await t.pumpAndSettle();
  await expectLater(find.byType(MaterialApp).last, matchesGoldenFile('goldens/$name.png'));
}

void main() {
  setUpAll(loadFonts);

  testWidgets('golden: mirror idle', (t) async {
    await snap(t, wrap(MirrorPage(mirror: fakeMirror(), receiverName: () => 'Mirada')), 'mirror_idle');
  });

  testWidgets('golden: devices empty', (t) async {
    final src = FakeSource();
    await snap(
        t,
        wrap(DevicesPage(discovery: DeviceDiscovery(src), mirror: fakeMirror())),
        'devices_empty');
    await src.controller.close();
  });

  testWidgets('golden: settings', (t) async {
    final s = await fakeSettings();
    await snap(t, wrap(SettingsPage(settings: s)), 'settings');
  });

  testWidgets('golden: about', (t) async {
    await snap(t, wrap(AboutPage(checker: IdleUpdateChecker())), 'about');
  });

  testWidgets('golden: full shell dark', (t) async {
    final s = await fakeSettings({'theme': 'dark'});
    await snap(
      t,
      MiradaApp(
        settings: s,
        discovery: DeviceDiscovery(FakeSource()),
        mirror: fakeMirror(),
        updateChecker: IdleUpdateChecker(),
        showTopBar: false,
      ),
      'shell_dark',
    );
  });
}
