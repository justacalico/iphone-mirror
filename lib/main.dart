import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/mirror.dart';
import 'services/settings.dart';
import 'services/update_checker.dart';
import 'services/window_controls.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.load();
  final discovery = DeviceDiscovery(EmptyDeviceSource());
  final receiver = ReceiverService(receiverName: () => settings.receiverName);
  final mirror = MirrorController(receiver);
  final checker = UpdateChecker();
  unawaited(initializeWindowIfDesktop(WindowManagerControls()));
  runApp(MiradaApp(
    settings: settings,
    discovery: discovery,
    mirror: mirror,
    updateChecker: checker,
  ));
}
