import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/app.dart';
import 'package:mirada/shell.dart';
import 'package:mirada/services/mirror.dart';
import 'package:mirada/services/settings.dart';
import 'package:mirada/widgets/top_bar.dart';

import 'pages_test.dart' show wrap;
import 'widget_test_helpers.dart';

Future<Widget> shellFixture({
  SettingsController? settings,
  bool? showTopBar,
  int initialIndex = 0,
}) async {
  final s = settings ?? await fakeSettings();
  final source = FakeSource();
  return MiradaApp(
    settings: s,
    discovery: DeviceDiscovery(source),
    mirror: fakeMirror(),
    updateChecker: IdleUpdateChecker(),
    showTopBar: showTopBar,
  );
}

void main() {
  testWidgets('app shell navigates all four pages', (t) async {
    await t.pumpWidget(await shellFixture(showTopBar: true));
    await t.pumpAndSettle();
    expect(find.text('Nothing mirrored yet'), findsOneWidget);
    await t.tap(find.text('Devices'));
    await t.pumpAndSettle();
    expect(find.text('No iPhones found yet'), findsOneWidget);
    await t.tap(find.text('Settings'));
    await t.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    await t.tap(find.text('About'));
    await t.pumpAndSettle();
    expect(find.text('Mirada'), findsWidgets);
    await t.tap(find.text('Mirror'));
    await t.pumpAndSettle();
    expect(find.text('Nothing mirrored yet'), findsOneWidget);
  });

  testWidgets('top bar hidden when requested', (t) async {
    await t.pumpWidget(await shellFixture(showTopBar: false));
    await t.pumpAndSettle();
    expect(find.byType(TopBar), findsNothing);
  });

  testWidgets('AppShell honors initialIndex', (t) async {
    final s = await fakeSettings();
    await t.pumpWidget(wrap(AppShell(
      settings: s,
      discovery: DeviceDiscovery(FakeSource()),
      mirror: fakeMirror(),
      updateChecker: IdleUpdateChecker(),
      initialIndex: 2,
      showTopBar: false,
    )));
    expect(find.text('Receiver name'), findsOneWidget);
  });

  testWidgets('zh locale renders Chinese labels', (t) async {
    final s = await fakeSettings({'language': 'zh'});
    await t.pumpWidget(await shellFixture(settings: s));
    await t.pumpAndSettle();
    expect(find.text('镜像'), findsOneWidget);
    expect(find.text('设备'), findsOneWidget);
  });

  testWidgets('ru and ga locales render', (t) async {
    for (final lang in ['ru', 'ga']) {
      final s = await fakeSettings({'language': lang});
      await t.pumpWidget(await shellFixture(settings: s));
      await t.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    }
  });

  testWidgets('oled theme produces black scaffold', (t) async {
    final s = await fakeSettings({'theme': 'oled', 'brightness': 'dark'});
    await t.pumpWidget(await shellFixture(settings: s));
    await t.pumpAndSettle();
    final app = t.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.darkTheme?.scaffoldBackgroundColor, Colors.black);
    expect(app.themeMode, ThemeMode.dark);
  });
}
