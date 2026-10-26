import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/services/window_controls.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void mock({bool maximized = false}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (call) async {
      if (call.method == 'isMaximized') return maximized;
      return null;
    });
  }

  test('WindowManagerControls calls through the channel', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (call) async {
      calls.add(call.method);
      if (call.method == 'isMaximized') return false;
      return null;
    });
    final c = WindowManagerControls();
    await c.initialize();
    expect(calls, containsAll(['ensureInitialized', 'setTitleBarStyle', 'setMinimumSize']));
    await c.close();
    await c.minimize();
    expect(await c.isMaximized(), isFalse);
    await c.toggleMaximize();
    expect(calls, contains('maximize'));
  });

  test('toggleMaximize unmaximizes when maximized', () async {
    mock(maximized: true);
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (call) async {
      calls.add(call.method);
      return call.method == 'isMaximized';
    });
    await WindowManagerControls().toggleMaximize();
    expect(calls, contains('unmaximize'));
  });
}
