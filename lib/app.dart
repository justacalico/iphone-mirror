import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'services/mirror.dart';
import 'services/settings.dart';
import 'services/update_checker.dart';
import 'shell.dart';
import 'theme.dart';

class MiradaApp extends StatelessWidget {
  const MiradaApp({
    super.key,
    required this.settings,
    required this.discovery,
    required this.mirror,
    required this.updateChecker,
    this.showTopBar,
  });

  final SettingsController settings;
  final DeviceDiscovery discovery;
  final MirrorController mirror;
  final UpdateChecker updateChecker;
  final bool? showTopBar;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Mirada',
          debugShowCheckedModeBanner: false,
          theme: lightTheme(),
          darkTheme: darkTheme(oled: settings.oled),
          themeMode: settings.materialThemeMode,
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppShell(
            settings: settings,
            discovery: discovery,
            mirror: mirror,
            updateChecker: updateChecker,
            showTopBar: showTopBar,
          ),
        );
      },
    );
  }
}
