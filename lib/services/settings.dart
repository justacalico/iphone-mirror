import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark, oled }

enum AppLanguage { system, enGB, zh, ru, ga }

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;

  static const _kTheme = 'theme';
  static const _kLanguage = 'language';
  static const _kReceiverName = 'receiver_name';
  static const _kResolution = 'resolution';
  static const _kFrameRate = 'frame_rate';
  static const _kRequirePin = 'require_pin';
  static const _kAvSync = 'av_sync';

  AppThemeMode get themeMode {
    final v = _prefs.getString(_kTheme);
    return AppThemeMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs.setString(_kTheme, mode.name);
    notifyListeners();
  }

  AppLanguage get language {
    final v = _prefs.getString(_kLanguage);
    return AppLanguage.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AppLanguage.system,
    );
  }

  Locale? get locale {
    switch (language) {
      case AppLanguage.system:
        return null;
      case AppLanguage.enGB:
        return const Locale('en', 'GB');
      case AppLanguage.zh:
        return const Locale('zh');
      case AppLanguage.ru:
        return const Locale('ru');
      case AppLanguage.ga:
        return const Locale('ga');
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    await _prefs.setString(_kLanguage, lang.name);
    notifyListeners();
  }

  String get receiverName => _prefs.getString(_kReceiverName) ?? 'Mirada';

  Future<void> setReceiverName(String name) async {
    await _prefs.setString(_kReceiverName, name);
    notifyListeners();
  }

  String get resolution => _prefs.getString(_kResolution) ?? '1920x1080';

  Future<void> setResolution(String value) async {
    await _prefs.setString(_kResolution, value);
    notifyListeners();
  }

  int get frameRate => _prefs.getInt(_kFrameRate) ?? 60;

  Future<void> setFrameRate(int value) async {
    await _prefs.setInt(_kFrameRate, value);
    notifyListeners();
  }

  bool get requirePin => _prefs.getBool(_kRequirePin) ?? false;

  Future<void> setRequirePin(bool value) async {
    await _prefs.setBool(_kRequirePin, value);
    notifyListeners();
  }

  bool get avSync => _prefs.getBool(_kAvSync) ?? false;

  Future<void> setAvSync(bool value) async {
    await _prefs.setBool(_kAvSync, value);
    notifyListeners();
  }

  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
        return ThemeMode.dark;
    }
  }

  bool get oled => themeMode == AppThemeMode.oled;

  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsController(prefs);
  }
}
