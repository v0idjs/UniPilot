import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/errors/startup_errors.dart';
import 'core/window/desktop_window.dart';

Future<void> main() async {
  final errorLog = StartupErrorLog();
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await installErrorHandlers(log: errorLog);
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
    try {
      runApp(const UniPilotApp());
    } catch (error, stack) {
      // Last resort: show what happened instead of a blank window.
      await errorLog.log('runApp', error, stack);
      runApp(StartupFailureApp(
        message: '$error',
        logPath: await _logPathOrNull(errorLog),
      ));
      return;
    }
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
  }, (Object error, StackTrace stack) {
    unawaited(errorLog.log('runZonedGuarded', error, stack));
  });
}

Future<String?> _logPathOrNull(StartupErrorLog log) async {
  try {
    return (await log.file()).path;
  } catch (_) {
    return null;
  }
}
