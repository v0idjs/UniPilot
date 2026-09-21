import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/deadlines/deadline_list_screen.dart';
import 'package:unipilot/features/schedule/schedule_screen.dart';

import '../fakes/fake_database.dart';
import '../fakes/fake_reminder_scheduler.dart';

/// Accessibility smoke tests (#13): key screens must build under maximum
/// text scaling without throwing (overflow errors surface as exceptions
/// in widget tests).
Future<void> _pumpScaled(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
      child: child,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('schedule screen survives 200% text scaling', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await db.createCourse(code: 'CS101', name: 'Introduction to CS');
    final course = (await db.watchCourses().first).single;
    await db.createEntry(
      courseId: course.id,
      dayOfWeek: 1,
      startMinutes: 540,
      endMinutes: 630,
    );

    await _pumpScaled(
      tester,
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ScheduleScreen()),
      ),
    );

    expect(find.textContaining('CS101'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deadlines screen survives 200% text scaling', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await db.createAssignment(
      title: 'A very long deadline title that wraps across lines',
      dueAt: DateTime.now().add(const Duration(days: 7)),
    );

    await _pumpScaled(
      tester,
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(NoopReminderScheduler()),
        ],
        child: const MaterialApp(home: DeadlineListScreen()),
      ),
    );

    expect(find.textContaining('very long deadline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
