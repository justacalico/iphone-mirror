import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/mirror.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key, required this.discovery, required this.mirror});

  final DeviceDiscovery discovery;
  final MirrorController mirror;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: discovery,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Expanded(child: Text(l.devicesTitle, style: Theme.of(context).textTheme.headlineSmall)),
                  FilledButton.tonalIcon(
                    onPressed: discovery.scanning ? null : discovery.scan,
                    icon: const Icon(Icons.bluetooth_searching, size: 18),
                    label: Text(discovery.scanning ? l.devicesScanning : l.devicesScan),
                  ),
                ],
              ),
            ),
            Expanded(
              child: discovery.devices.isEmpty
                  ? _EmptyState(label: l.devicesNone, hint: l.devicesHint)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: discovery.devices.length,
                      itemBuilder: (context, i) {
                        final p = discovery.devices[i];
                        final connected = mirror.device?.id == p.id && mirror.status != MirrorStatus.idle;
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.smartphone),
                            title: Text(p.name),
                            subtitle: Text(connected ? l.devicesConnected : (p.paired ? l.devicesPaired : l.devicesTapConnect)),
                            trailing: connected ? const Icon(Icons.check_circle) : const Icon(Icons.chevron_right),
                            onTap: connected ? null : () => mirror.connect(p),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smartphone_outlined, size: 56, color: colors.outline),
            const SizedBox(height: 16),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
