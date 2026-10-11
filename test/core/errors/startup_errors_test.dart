import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/errors/startup_errors.dart';

void main() {
  // Polls for the unawaited file write instead of a fixed delay, so the
  // test stays deterministic when the full suite is under load.
  Future<String> readSoon(File file) async {
    final DateTime deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      if (await file.exists()) {
        final String content = await file.readAsString();
        if (content.isNotEmpty) return content;
      }
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
    if (await file.exists()) {
      return file.readAsString();
    }
    return '';
  }

  // Best-effort temp cleanup: Windows file locking (Defender, search
  // indexer) may briefly hold freshly written files, so a failing
  // delete must not fail the test. The OS reclaims Temp regardless.
  Future<void> deleteSoon(Directory dir) async {
    try {
      await dir.delete(recursive: true);
    } catch (_) {
      // Ignore: see above.
    }
  }

  group('StartupErrorLog.formatLine', () {
    test('includes timestamp, kind and message', () {
      final log = StartupErrorLog(
        directory: Directory.systemTemp,
        clock: () => DateTime.utc(2026, 1, 2, 3, 4, 5),
      );
      final line = log.formatLine('runApp', StateError('boom'));
      expect(line, contains('2026-01-02T03:04:05.000Z'));
      expect(line, contains('runApp'));
      expect(line, contains('boom'));
    });

    test('appends stack trace when provided', () {
      final log = StartupErrorLog(
        directory: Directory.systemTemp,
        clock: () => DateTime.utc(2026, 1, 2),
      );
      final stack = StackTrace.fromString('frame-one\nframe-two');
      final line = log.formatLine('zone', 'bad', stack);
      expect(line, contains('frame-one'));
      expect(line, contains('frame-two'));
    });
  });

  group('StartupErrorLog.append', () {
    test('creates the file and appends lines', () async {
      final dir = await Directory.systemTemp.createTemp('unipilot-log');
      addTearDown(() => deleteSoon(dir));
      final log = StartupErrorLog(directory: dir);

      await log.append('first');
      await log.append('second');

      final file = File('${dir.path}/unipilot-error.log');
      expect(await file.exists(), isTrue);
      expect(await file.readAsString(), 'first\nsecond\n');
    });

    test('rotates an oversized log instead of growing it', () async {
      final dir = await Directory.systemTemp.createTemp('unipilot-rotate');
      addTearDown(() => deleteSoon(dir));
      final file = File('${dir.path}/unipilot-error.log');
      await file.writeAsString('x' * (StartupErrorLog.maxBytes + 1));
      final log = StartupErrorLog(directory: dir);

      await log.append('fresh');

      expect(await file.readAsString(), 'fresh\n');
    });

    test('never throws, even on an unwritable location', () async {
      final dir = await Directory.systemTemp.createTemp('unipilot-bad');
      addTearDown(() => deleteSoon(dir));
      // A regular file where a directory is expected: creating the
      // log directory — and every later IO op — fails inside `append`.
      final blocker = File('${dir.path}/blocker');
      await blocker.writeAsString('x');
      final log = StartupErrorLog(
        directory: Directory('${blocker.path}/sub'),
      );
      await log.append('lost');
      // Nothing may leak: no log file appears at the bad location.
      final leaked = File(
        '${blocker.path}/sub/${StartupErrorLog.fileName}',
      );
      expect(await leaked.exists(), isFalse);
    });
  });

  group('installErrorHandlers', () {
    test('installs and restores framework handlers', () async {
      final previousFlutter = FlutterError.onError;
      final previousDispatcher = PlatformDispatcher.instance.onError;
      addTearDown(() {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousDispatcher;
      });

      await installErrorHandlers();

      expect(FlutterError.onError, isNotNull);
      expect(PlatformDispatcher.instance.onError, isNotNull);
    });

    test('framework handler logs without throwing', () async {
      final dir = await Directory.systemTemp.createTemp('unipilot-hook');
      addTearDown(() => deleteSoon(dir));
      final previousFlutter = FlutterError.onError;
      addTearDown(() => FlutterError.onError = previousFlutter);

      await installErrorHandlers(log: StartupErrorLog(directory: dir));
      FlutterError.reportError(
        FlutterErrorDetails(exception: StateError('ui-boom')),
      );

      final String content =
          await readSoon(File('${dir.path}/unipilot-error.log'));
      expect(content, contains('FlutterError.onError'));
      expect(content, contains('ui-boom'));
    });
  });

  group('StartupFailureApp', () {
    testWidgets('shows the failure message and log path', (tester) async {
      await tester.pumpWidget(
        const StartupFailureApp(
          message: 'Startup failed badly',
          logPath: 'C:/logs/unipilot-error.log',
        ),
      );
      expect(find.text('Startup failed badly'), findsOneWidget);
      expect(find.textContaining('unipilot-error.log'), findsOneWidget);
    });

    testWidgets('works without a log path', (tester) async {
      await tester.pumpWidget(
        const StartupFailureApp(message: 'Startup failed badly'),
      );
      expect(find.text('Startup failed badly'), findsOneWidget);
    });
  });
}
