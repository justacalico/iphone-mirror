import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.settingsTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: settings.receiverName)
                ..selection = TextSelection.collapsed(offset: settings.receiverName.length),
              decoration: InputDecoration(
                labelText: l.settingsReceiverName,
                helperText: l.settingsReceiverNameHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: settings.setReceiverName,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: settings.resolution,
              decoration: InputDecoration(labelText: l.settingsResolution, border: const OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: '1280x720', child: Text('1280x720')),
                DropdownMenuItem(value: '1920x1080', child: Text('1920x1080')),
                DropdownMenuItem(value: '2560x1440', child: Text('2560x1440')),
              ],
              onChanged: (v) => settings.setResolution(v ?? settings.resolution),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: settings.frameRate,
              decoration: InputDecoration(labelText: l.settingsFrameRate, border: const OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 30, child: Text('30')),
                DropdownMenuItem(value: 60, child: Text('60')),
                DropdownMenuItem(value: 90, child: Text('90')),
                DropdownMenuItem(value: 120, child: Text('120')),
              ],
              onChanged: (v) => settings.setFrameRate(v ?? settings.frameRate),
            ),
            SwitchListTile(
              title: Text(l.settingsPin),
              value: settings.requirePin,
              onChanged: settings.setRequirePin,
            ),
            SwitchListTile(
              title: Text(l.settingsAvSync),
              value: settings.avSync,
              onChanged: settings.setAvSync,
            ),
            const Divider(height: 32),
            DropdownButtonFormField<AppLanguage>(
              initialValue: settings.language,
              decoration: InputDecoration(labelText: l.settingsLanguage, border: const OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: AppLanguage.system, child: Text(l.languageSystem)),
                DropdownMenuItem(value: AppLanguage.enGB, child: Text(l.languageEnGB)),
                DropdownMenuItem(value: AppLanguage.zh, child: Text(l.languageZh)),
                DropdownMenuItem(value: AppLanguage.ru, child: Text(l.languageRu)),
                DropdownMenuItem(value: AppLanguage.ga, child: Text(l.languageGa)),
              ],
              onChanged: (v) => settings.setLanguage(v ?? settings.language),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppThemeMode>(
              initialValue: settings.themeMode,
              decoration: InputDecoration(labelText: l.settingsTheme, border: const OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: AppThemeMode.system, child: Text(l.themeSystem)),
                DropdownMenuItem(value: AppThemeMode.light, child: Text(l.themeLight)),
                DropdownMenuItem(value: AppThemeMode.dark, child: Text(l.themeDark)),
                DropdownMenuItem(value: AppThemeMode.oled, child: Text(l.themeOled)),
              ],
              onChanged: (v) => settings.setThemeMode(v ?? settings.themeMode),
            ),
          ],
        );
      },
    );
  }
}
