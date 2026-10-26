import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/mirror.dart';

class MirrorPage extends StatelessWidget {
  const MirrorPage({super.key, required this.mirror, required this.receiverName});

  final MirrorController mirror;
  final String Function() receiverName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: mirror,
      builder: (context, _) {
        switch (mirror.status) {
          case MirrorStatus.idle:
            return _Hint(
              icon: Icons.smartphone_outlined,
              title: l.mirrorIdleTitle,
              body: l.mirrorIdleHint,
            );
          case MirrorStatus.connecting:
            return _Hint(
              icon: Icons.sync,
              title: l.mirrorConnecting,
              body: '',
            );
          case MirrorStatus.waiting:
            return _MirrorSurface(
              title: mirror.device?.name ?? '',
              body: l.mirrorWaitingVideo(receiverName()),
              onDisconnect: mirror.disconnect,
              disconnectLabel: l.mirrorDisconnect,
            );
          case MirrorStatus.error:
            return _Hint(
              icon: Icons.error_outline,
              title: l.mirrorError(mirror.error ?? ''),
              body: l.receiverUxplayMissing,
            );
        }
      },
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MirrorSurface extends StatelessWidget {
  const _MirrorSurface({
    required this.title,
    required this.body,
    required this.onDisconnect,
    required this.disconnectLabel,
  });

  final String title;
  final String body;
  final VoidCallback onDisconnect;
  final String disconnectLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Material(
          color: colors.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.smartphone, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
                TextButton(onPressed: onDisconnect, child: Text(disconnectLabel)),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.outlineVariant, width: 6),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
