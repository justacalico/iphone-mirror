import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('landing renders', (t) async {
    t.view.physicalSize = const Size(1400, 1200);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const LandingApp());
    expect(find.text('Mirada'), findsWidgets);
    expect(find.textContaining('Linux'), findsWidgets);
  });
}
