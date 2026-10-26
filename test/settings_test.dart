import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/services/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsController> _load([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return SettingsController.load();
}

Future<SettingsController> _reload() async =>
    SettingsController(await SharedPreferences.getInstance());

void main() {
  test('defaults', () async {
    final s = await _load();
    expect(s.themeMode, AppThemeMode.system);
    expect(s.language, AppLanguage.system);
    expect(s.locale, isNull);
    expect(s.receiverName, 'Mirada');
    expect(s.resolution, '1920x1080');
    expect(s.frameRate, 60);
    expect(s.requirePin, isFalse);
    expect(s.avSync, isFalse);
    expect(s.oled, isFalse);
    expect(s.materialThemeMode, ThemeMode.system);
  });

  test('theme persistence and material mapping', () async {
    final s = await _load();
    var notified = 0;
    s.addListener(() => notified++);
    await s.setThemeMode(AppThemeMode.oled);
    expect(s.themeMode, AppThemeMode.oled);
    expect(s.materialThemeMode, ThemeMode.dark);
    expect(s.oled, isTrue);
    await s.setThemeMode(AppThemeMode.light);
    expect(s.materialThemeMode, ThemeMode.light);
    await s.setThemeMode(AppThemeMode.dark);
    expect(s.materialThemeMode, ThemeMode.dark);
    expect(notified, 3);
    final reloaded = await _reload();
    expect(reloaded.themeMode, AppThemeMode.dark);
  });

  test('language persistence and locales', () async {
    final s = await _load();
    await s.setLanguage(AppLanguage.zh);
    expect(s.locale, const Locale('zh'));
    await s.setLanguage(AppLanguage.ru);
    expect(s.locale, const Locale('ru'));
    await s.setLanguage(AppLanguage.ga);
    expect(s.locale, const Locale('ga'));
    await s.setLanguage(AppLanguage.enGB);
    expect(s.locale, const Locale('en', 'GB'));
    await s.setLanguage(AppLanguage.system);
    expect(s.locale, isNull);
    final reloaded = await _reload();
    expect(reloaded.language, AppLanguage.system);
  });

  test('unknown stored values fall back to defaults', () async {
    final s = await _load({'theme': 'neon', 'language': 'klingon'});
    expect(s.themeMode, AppThemeMode.system);
    expect(s.language, AppLanguage.system);
  });

  test('receiver fields round-trip and notify', () async {
    final s = await _load();
    var notified = 0;
    s.addListener(() => notified++);
    await s.setReceiverName('Desk');
    await s.setResolution('2560x1440');
    await s.setFrameRate(120);
    await s.setRequirePin(true);
    await s.setAvSync(true);
    expect(notified, 5);
    final reloaded = await _reload();
    expect(reloaded.receiverName, 'Desk');
    expect(reloaded.resolution, '2560x1440');
    expect(reloaded.frameRate, 120);
    expect(reloaded.requirePin, isTrue);
    expect(reloaded.avSync, isTrue);
  });
}
