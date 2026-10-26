import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'pages/about_page.dart';
import 'pages/devices_page.dart';
import 'pages/mirror_page.dart';
import 'pages/settings_page.dart';
import 'services/mirror.dart';
import 'services/settings.dart';
import 'services/update_checker.dart';
import 'services/window_controls.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.settings,
    required this.discovery,
    required this.mirror,
    required this.updateChecker,
    this.windowControls,
    this.initialIndex = 0,
    this.showTopBar,
  });

  final SettingsController settings;
  final DeviceDiscovery discovery;
  final MirrorController mirror;
  final UpdateChecker updateChecker;
  final WindowControls? windowControls;
  final int initialIndex;
  final bool? showTopBar;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final destinations = [
      SidebarDestination(Icons.smartphone, l.navMirror),
      SidebarDestination(Icons.devices, l.navDevices),
      SidebarDestination(Icons.settings, l.navSettings),
      SidebarDestination(Icons.info_outline, l.navAbout),
    ];
    final pages = [
      MirrorPage(mirror: widget.mirror, receiverName: () => widget.settings.receiverName),
      DevicesPage(discovery: widget.discovery, mirror: widget.mirror),
      SettingsPage(settings: widget.settings),
      AboutPage(checker: widget.updateChecker),
    ];
    final showTopBar = widget.showTopBar ?? isDesktop;
    return Scaffold(
      body: Column(
        children: [
          if (showTopBar) TopBar(title: l.appTitle, controls: widget.windowControls),
          Expanded(
            child: Row(
              children: [
                MiradaSidebar(
                  destinations: destinations,
                  selectedIndex: _index,
                  onSelect: (i) => setState(() => _index = i),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[_index]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
