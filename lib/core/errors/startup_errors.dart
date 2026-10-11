import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Startup and fatal-error reporting (issue #17).
///
/// Framework errors, platform-dispatcher errors, and zone errors are
/// appended to `unipilot-error.log` in the app support directory, so a
/// failure during launch leaves evidence instead of a blank window.
/// Every file operation is guarded: logging must never throw.
class StartupErrorLog {
  StartupErrorLog({Directory? directory, DateTime Function()? clock})
      : _directory = directory,
        _clock = clock ?? DateTime.now;

  static const String fileName = 'unipilot-error.log';

  /// Rotate instead of growing past this.
  static const int maxBytes = 64 * 1024;

  final Directory? _directory;
  final DateTime Function() _clock;

  Future<Directory> _resolveDirectory() async {
    final override = _directory;
    if (override != null) return override;
    // Same folder as the database, so one location holds both the
    // data file users may need to delete and the log they may be
    // asked to attach. See `docs/windows.md`.
    return getApplicationDocumentsDirectory();
  }

  /// Where the log lives. Documented in `docs/windows.md`.
  Future<File> file() async {
    final dir = await _resolveDirectory();
    return File(p.join(dir.path, fileName));
  }

  String formatLine(String kind, Object error, [StackTrace? stack]) {
    final buffer = StringBuffer()
      ..write('[')
      ..write(_clock().toIso8601String())
      ..write('] ')
      ..write(kind)
      ..write(': ')
      ..write(error);
    final trace = stack;
    if (trace != null) {
      buffer.write('\n');
      buffer.write(trace);
    }
    return buffer.toString();
  }

  /// Appends [line]; never throws.
  Future<void> append(String line) async {
    try {
      final target = await file();
      await target.parent.create(recursive: true);
      if (await target.exists() && await target.length() > maxBytes) {
        await target.delete();
      }
      await target.writeAsString(
        '$line\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Deliberately swallowed: logging must not break the app.
    }
  }

  Future<void> log(String kind, Object error, [StackTrace? stack]) =>
      append(formatLine(kind, error, stack));
}

/// Installs process-wide handlers that log to [StartupErrorLog.file].
///
/// `FlutterError.onError` still presents errors as before; the
/// platform-dispatcher hook returns true so an async failure is recorded
/// instead of taking the process down silently.
Future<void> installErrorHandlers({StartupErrorLog? log}) async {
  final errorLog = log ?? StartupErrorLog();
  FlutterError.onError = (FlutterErrorDetails details) {
    unawaited(errorLog.log(
      'FlutterError.onError',
      details.exception,
      details.stack,
    ));
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    unawaited(errorLog.log('PlatformDispatcher.onError', error, stack));
    return true;
  };
}

/// Minimal branded screen shown when startup itself fails, so users see
/// what happened (and where the log is) instead of a blank window.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key, required this.message, this.logPath});

  final String message;
  final String? logPath;

  @override
  Widget build(BuildContext context) {
    final path = logPath;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  'UniPilot could not start',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                if (path != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'Details were written to $path',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
