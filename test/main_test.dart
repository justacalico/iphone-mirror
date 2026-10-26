import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/main.dart' as app;
import 'package:mirada/services/window_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget_test_helpers.dart';

void main() {
  testWidgets('main boots the app', (t) async {
    SharedPreferences.setMockInitialValues({});
    mockWindowManagerChannel();
    await app.main();
    await t.pumpAndSettle();
    expect(find.text('Nothing mirrored yet'), findsOneWidget);
  });

  test('isDesktop and initializeWindowIfDesktop', () async {
    expect(isDesktop, isTrue);
    final c = FakeWindowControls();
    await initializeWindowIfDesktop(c);
    expect(c.initialized, isTrue);
    final bad = FakeWindowControls()..throwOnInit = true;
    await initializeWindowIfDesktop(bad);
  });
}
