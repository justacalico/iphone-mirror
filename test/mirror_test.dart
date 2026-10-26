import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/services/mirror.dart';

class FakeHandle implements ReceiverHandle {
  int kills = 0;

  @override
  void kill() => kills++;
}

class FakeLauncher implements ReceiverLauncher {
  final args = <List<String>>[];
  final handle = FakeHandle();
  bool throws = false;

  @override
  Future<ReceiverHandle> start(List<String> a) async {
    if (throws) throw Exception('spawn');
    args.add(a);
    return handle;
  }
}

class FakeSource implements DeviceSource {
  final controller = StreamController<List<Phone>>.broadcast();
  int scans = 0;

  @override
  Stream<List<Phone>> get devices => controller.stream;

  @override
  Future<void> scan() async {
    scans++;
    controller.add([const Phone(id: '1', name: 'iPhone', paired: true)]);
  }
}

void main() {
  group('DeviceDiscovery', () {
    test('emits device lists and clears scanning', () async {
      final source = FakeSource();
      final d = DeviceDiscovery(source);
      await d.scan();
      expect(d.scanning, isFalse);
      expect(d.devices.single.name, 'iPhone');
      d.dispose();
      await source.controller.close();
    });
  });

  group('EmptyDeviceSource', () {
    test('scan emits an empty list and close is safe', () async {
      final s = EmptyDeviceSource();
      final values = <List<Phone>>[];
      final sub = s.devices.listen(values.add);
      await s.scan();
      await s.close();
      await sub.cancel();
      expect(values.single, isEmpty);
    });
  });

  group('ReceiverService', () {
    Future<ProcessResult> okRunner(exe, args) async => ProcessResult(0, 0, '', '');
    Future<ProcessResult> failRunner(exe, args) async => ProcessResult(0, 1, '', '');

    test('uxplayAvailable maps exit code and errors', () async {
      final r = ReceiverService(run: okRunner, receiverName: () => 'Mirada');
      expect(await r.uxplayAvailable(), isTrue);
      final r2 = ReceiverService(run: failRunner, receiverName: () => 'Mirada');
      expect(await r2.uxplayAvailable(), isFalse);
      final r3 = ReceiverService(run: (e, a) => throw Exception('x'), receiverName: () => 'Mirada');
      expect(await r3.uxplayAvailable(), isFalse);
    });

    test('start fails without uxplay', () async {
      final r = ReceiverService(run: failRunner, receiverName: () => 'Mirada');
      expect(await r.start(), isFalse);
      expect(r.running, isFalse);
    });

    test('start spawns uxplay and stop kills it', () async {
      final launcher = FakeLauncher();
      final r = ReceiverService(run: okRunner, launcher: launcher, receiverName: () => 'Desk');
      expect(await r.start(), isTrue);
      expect(r.running, isTrue);
      expect(launcher.args.single, containsAllInOrder(['-n', 'Desk', '-nh']));
      expect(await r.start(), isTrue);
      expect(launcher.args, hasLength(1));
      await r.stop();
      expect(r.running, isFalse);
      expect(launcher.handle.kills, 1);
      await r.stop();
      expect(launcher.handle.kills, 1);
    });

    test('start returns false when spawn throws', () async {
      final r = ReceiverService(
        run: okRunner,
        launcher: FakeLauncher()..throws = true,
        receiverName: () => 'Mirada',
      );
      expect(await r.start(), isFalse);
    });
  });

  group('UxplayLauncher', () {
    test('launches a real process and kills it', () async {
      final launcher = UxplayLauncher('echo');
      final h = await launcher.start(['hi']);
      h.kill();
      final launcher2 = UxplayLauncher();
      expect(launcher2.executable, 'uxplay');
    });
  });

  test('Phone fields', () {
    final p = Phone(id: 'a', name: 'b');
    expect(p.paired, isFalse);
    expect(Phone(id: 'a', name: 'b', paired: true).paired, isTrue);
  });

  group('MirrorController', () {
    final phone = const Phone(id: '9', name: 'My iPhone');

    MirrorController ok() => MirrorController(ReceiverService(
          run: (e, a) async => ProcessResult(0, 0, '', ''),
          launcher: FakeLauncher(),
          receiverName: () => 'Mirada',
        ));

    test('connect transitions to waiting on success', () async {
      final m = ok();
      await m.connect(phone);
      expect(m.status, MirrorStatus.waiting);
      expect(m.device, phone);
      final second = m.connect(phone);
      await m.disconnect();
      await second;
      expect(m.status, MirrorStatus.idle);
      expect(m.device, isNull);
    });

    test('connect fails to error state without uxplay', () async {
      final m = MirrorController(ReceiverService(
        run: (e, a) async => ProcessResult(0, 1, '', ''),
        receiverName: () => 'Mirada',
      ));
      await m.connect(phone);
      expect(m.status, MirrorStatus.error);
      expect(m.error, 'uxplay');
    });
  });
}
