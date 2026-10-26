import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/widgets/sidebar.dart';

void main() {
  final dests = const [
    SidebarDestination(Icons.smartphone, 'Mirror'),
    SidebarDestination(Icons.devices, 'Devices'),
    SidebarDestination(Icons.settings, 'Settings'),
  ];

  testWidgets('renders rows and reports taps', (t) async {
    var picked = -1;
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MiradaSidebar(
          destinations: dests,
          selectedIndex: 1,
          onSelect: (i) => picked = i,
        ),
      ),
    ));
    expect(find.text('Mirror'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    await t.tap(find.text('Settings'));
    expect(picked, 2);
    await t.tap(find.text('Mirror'));
    expect(picked, 0);
  });
}
