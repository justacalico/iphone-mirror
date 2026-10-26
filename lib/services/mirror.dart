import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class Phone {
  final String id;
  final String name;
  final bool paired;
  const Phone({required this.id, required this.name, this.paired = false});
}

enum MirrorStatus { idle, connecting, waiting, error }

abstract class DeviceSource {
  Stream<List<Phone>> get devices;
  Future<void> scan();
}

class EmptyDeviceSource implements DeviceSource {
  final _controller = StreamController<List<Phone>>.broadcast();

  @override
  Stream<List<Phone>> get devices => _controller.stream;

  @override
  Future<void> scan() async {
    if (!_controller.isClosed) _controller.add(const []);
  }

  Future<void> close() => _controller.close();
}

class DeviceDiscovery extends ChangeNotifier {
  DeviceDiscovery(this._source) {
    _sub = _source.devices.listen((list) {
      _devices = list;
      _scanning = false;
      notifyListeners();
    });
  }

  final DeviceSource _source;
  StreamSubscription<List<Phone>>? _sub;
  List<Phone> _devices = const [];
  bool _scanning = false;

  List<Phone> get devices => _devices;
  bool get scanning => _scanning;

  Future<void> scan() async {
    _scanning = true;
    notifyListeners();
    await _source.scan();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

typedef ProcessRunner = Future<ProcessResult> Function(String exe, List<String> args);

abstract class ReceiverHandle {
  void kill();
}

abstract class ReceiverLauncher {
  Future<ReceiverHandle> start(List<String> args);
}

class _ProcessHandle implements ReceiverHandle {
  _ProcessHandle(this._p);
  final Process _p;

  @override
  void kill() => _p.kill();
}

class UxplayLauncher implements ReceiverLauncher {
  UxplayLauncher([this.executable = 'uxplay']);

  final String executable;

  @override
  Future<ReceiverHandle> start(List<String> args) async =>
      _ProcessHandle(await Process.start(executable, args));
}

class ReceiverService extends ChangeNotifier {
  ReceiverService({
    ProcessRunner? run,
    ReceiverLauncher? launcher,
    required this.receiverName,
  })  : _run = run ?? Process.run,
        _launcher = launcher ?? UxplayLauncher();

  final ProcessRunner _run;
  final ReceiverLauncher _launcher;
  final String Function() receiverName;

  ReceiverHandle? _handle;
  bool _running = false;

  bool get running => _running;

  Future<bool> uxplayAvailable() async {
    try {
      final res = await _run('which', const ['uxplay']);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> start() async {
    if (_running) return true;
    if (!await uxplayAvailable()) return false;
    try {
      _handle = await _launcher.start([
        '-n', receiverName(),
        '-nh',
        '-s', '1920x1080@60',
        '-fps', '60',
        '-nc',
        '-nohold',
        '-p', '7000',
      ]);
      _running = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    _handle?.kill();
    _handle = null;
    _running = false;
    notifyListeners();
  }
}

class MirrorController extends ChangeNotifier {
  MirrorController(this._receiver);

  final ReceiverService _receiver;

  MirrorStatus _status = MirrorStatus.idle;
  Phone? _device;
  String? _error;

  MirrorStatus get status => _status;
  Phone? get device => _device;
  String? get error => _error;

  Future<void> connect(Phone phone) async {
    if (_status == MirrorStatus.connecting) return;
    _device = phone;
    _status = MirrorStatus.connecting;
    _error = null;
    notifyListeners();
    final ok = await _receiver.start();
    if (!ok) {
      _status = MirrorStatus.error;
      _error = 'uxplay';
      notifyListeners();
      return;
    }
    _status = MirrorStatus.waiting;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _receiver.stop();
    _status = MirrorStatus.idle;
    _device = null;
    notifyListeners();
  }
}
