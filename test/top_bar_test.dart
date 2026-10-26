import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/widgets/top_bar.dart';

import 'pages_test.dart' show wrap;
import 'widget_test_helpers.dart';

Widget _wrap(Widget child) => wrap(Scaffold(body: child));

void main() {
  testWidgets('TopBar shows title and preferred size', (t) async {
    final c = FakeWindowControls();
    await t.pumpWidget(_wrap(TopBar(title: 'Mirada', controls: c)));
    expect(find.text('Mirada'), findsOneWidget);
    const bar = TopBar(title: 'x');
    expect(bar.preferredSize.height, TopBar.barHeight);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Minimise'), findsOneWidget);
    expect(find.byTooltip('Maximise'), findsOneWidget);
  });

  testWidgets('traffic light buttons call window controls', (t) async {
    final c = FakeWindowControls();
    await t.pumpWidget(_wrap(TrafficLights(controls: c)));
    await t.tap(find.byTooltip('Close'));
    await t.tap(find.byTooltip('Minimise'));
    await t.tap(find.byTooltip('Maximise'));
    expect(c.closes, 1);
    expect(c.minimizes, 1);
    expect(c.maximizes, 1);
  });

  testWidgets('hover reveals glyphs', (t) async {
    await t.pumpWidget(_wrap(TrafficLights(controls: FakeWindowControls())));
    expect(find.byIcon(Icons.close), findsNothing);
    final gesture = await t.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: t.getCenter(find.byType(TrafficLights)));
    await t.pump();
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await gesture.removePointer();
    await t.pump();
    expect(find.byIcon(Icons.close), findsNothing);
  });
}
