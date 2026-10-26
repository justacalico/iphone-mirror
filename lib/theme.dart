import 'package:flutter/material.dart';

const _seed = Color(0xFF4C5BD4);

ThemeData lightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: scheme.surface,
  );
}

ThemeData darkTheme({bool oled = false}) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);
  final colors = oled
      ? scheme.copyWith(
          surface: Colors.black,
          surfaceContainerLowest: Colors.black,
          surfaceContainerLow: const Color(0xFF0A0A0A),
          surfaceContainer: const Color(0xFF121212),
          surfaceContainerHigh: const Color(0xFF1A1A1A),
          surfaceContainerHighest: const Color(0xFF222222),
        )
      : scheme;
  return ThemeData(
    colorScheme: colors,
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: oled ? Colors.black : scheme.surface,
  );
}
