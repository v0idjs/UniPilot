import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/window/desktop_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      buildDesktopWindowOptions(),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }
  runApp(const UniPilotApp());
}
