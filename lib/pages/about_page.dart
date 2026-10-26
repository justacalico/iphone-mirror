import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/update_checker.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, required this.checker, this.packageInfo});

  final UpdateChecker checker;
  final PackageInfo? packageInfo;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  UpdateState _state = const UpdateIdle();

  Future<void> _check() async {
    setState(() => _state = const UpdateChecking());
    final s = await widget.checker.check();
    if (mounted) setState(() => _state = s);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final version = widget.packageInfo?.version ?? '0.1.0';
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(child: Image.asset('assets/icon.png', width: 96, height: 96)),
        const SizedBox(height: 16),
        Center(child: Text(l.appTitle, style: Theme.of(context).textTheme.headlineMedium)),
        Center(child: Text(l.aboutTagline, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(height: 8),
        Center(child: Text(l.aboutVersion(version), style: Theme.of(context).textTheme.bodySmall)),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.system_update_alt),
          title: Text(l.checkUpdates),
          subtitle: _subtitle(l),
          trailing: _state is UpdateChecking
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right),
          onTap: _check,
        ),
        ListTile(
          leading: const Icon(Icons.link),
          title: Text(l.aboutProject),
          subtitle: Text(widget.checker.projectUrl),
        ),
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(l.aboutLicenses),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(
            context: context,
            applicationName: l.appTitle,
            applicationVersion: version,
          ),
        ),
      ],
    );
  }

  Widget _subtitle(AppLocalizations l) {
    final s = _state;
    return switch (s) {
      UpdateChecking() => Text(l.updateChecking),
      UpdateUpToDate() => Text(l.updateUpToDate),
      UpdateFailed() => Text(l.updateFailed),
      UpdateAvailable() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.updateAvailable(s.version.toString())),
            Text(s.url, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
