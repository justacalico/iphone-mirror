import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Size;
import 'package:window_manager/window_manager.dart';

abstract class WindowControls {
  Future<void> initialize();
  Future<void> close();
  Future<void> minimize();
  Future<void> toggleMaximize();
  Future<bool> isMaximized();
}

class WindowManagerControls implements WindowControls {
  @override
  Future<void> initialize() async {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setMinimumSize(const Size(720, 560));
  }

  @override
  Future<void> close() => windowManager.close();

  @override
  Future<void> minimize() => windowManager.minimize();

  @override
  Future<void> toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Future<bool> isMaximized() => windowManager.isMaximized();
}

bool get isDesktop =>
    !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

Future<void> initializeWindowIfDesktop(WindowControls controls) async {
  if (!isDesktop) return;
  try {
    await controls.initialize();
  } catch (_) {}
}
