import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/window/desktop_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (details) {
    assert(() {
      debugPrint(details.toString());
      return true;
    }());
    return const Material(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Please restart the app.'),
        ]),
      ),
    );
  };
  // Paint content first: a throwing or hanging window API call must never
  // block startup, otherwise the desktop window stays blank.
  runApp(const UniPilotApp());
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      await windowManager.ensureInitialized();
      await windowManager.waitUntilReadyToShow(
        buildDesktopWindowOptions(),
        () async {
          await windowManager.show();
          await windowManager.focus();
        },
      );
    } catch (_) {
      // Desktop window setup is best effort; the app is already running.
    }
  }
}
