import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/services/mirror.dart';
import 'package:mirada/services/settings.dart';
import 'package:mirada/services/update_checker.dart';
import 'package:mirada/services/window_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWindowControls implements WindowControls {
  int closes = 0;
  int minimizes = 0;
  int maximizes = 0;
  bool initialized = false;
  bool maximized = false;
  bool throwOnInit = false;

  @override
  Future<void> initialize() async {
    if (throwOnInit) throw Exception('no window');
    initialized = true;
  }

  @override
  Future<void> close() async => closes++;

  @override
  Future<void> minimize() async => minimizes++;

  @override
  Future<void> toggleMaximize() async {
    maximizes++;
    maximized = !maximized;
  }

  @override
  Future<bool> isMaximized() async => maximized;
}

class FakeSource implements DeviceSource {
  final controller = StreamController<List<Phone>>.broadcast();
  List<Phone> seed = const [];

  @override
  Stream<List<Phone>> get devices => controller.stream;

  @override
  Future<void> scan() async => controller.add(seed);
}

class _FakeHandle implements ReceiverHandle {
  @override
  void kill() {}
}

class _FakeLauncher implements ReceiverLauncher {
  @override
  Future<ReceiverHandle> start(List<String> args) async => _FakeHandle();
}

MirrorController fakeMirror({bool ok = true}) {
  return MirrorController(ReceiverService(
    run: (e, a) async => ProcessResult(0, ok ? 0 : 1, '', ''),
    launcher: _FakeLauncher(),
    receiverName: () => 'Mirada',
  ));
}

class IdleUpdateChecker extends UpdateChecker {
  IdleUpdateChecker() : super();

  @override
  Future<UpdateState> check() async => const UpdateUpToDate();
}

Future<SettingsController> fakeSettings([Map<String, Object> v = const {}]) async {
  SharedPreferences.setMockInitialValues(v);
  return SettingsController.load();
}

void mockWindowManagerChannel({bool maximized = false}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('window_manager'), (call) async {
    switch (call.method) {
      case 'isMaximized':
        return maximized;
      case 'ensureInitialized':
      case 'setTitleBarStyle':
      case 'setMinimumSize':
      case 'close':
      case 'minimize':
      case 'maximize':
      case 'unmaximize':
      case 'waitUntilReadyToShow':
        return null;
      default:
        return null;
    }
  });
}
