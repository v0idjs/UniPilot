import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/deadlines/deadline_list_screen.dart';

import '../../fakes/fake_database.dart';
import '../../fakes/fake_reminder_scheduler.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

ProviderScope _scope(FakeUniPilotDatabase db, RecordingReminderScheduler rs) {
  return ProviderScope(
    overrides: [
      dbProvider.overrideWithValue(db),
      reminderSchedulerProvider.overrideWithValue(rs),
    ],
    child: const MaterialApp(home: DeadlineListScreen()),
  );
}

void main() {
  testWidgets('saving a deadline schedules a reminder', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    final rs = RecordingReminderScheduler();

    await tester.pumpWidget(_scope(db, rs));
    await _pump(tester);

    await tester.tap(find.text('Add Deadline'));
    await _pump(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Essay',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(rs.scheduled, hasLength(1));
    expect(rs.scheduled.single.title, 'Essay');
    expect(rs.scheduled.single.dueAt.hour, 23);
    expect(rs.scheduled.single.dueAt.minute, 59);
    // The scheduled id matches the persisted row id.
    final items = await db.watchAssignments().first;
    expect(rs.scheduled.single.id, items.single.id);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('completing a deadline cancels its reminder', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    final rs = RecordingReminderScheduler();
    final id = await db.createAssignment(
      title: 'Essay',
      dueAt: DateTime.now().add(const Duration(days: 7)),
    );

    await tester.pumpWidget(_scope(db, rs));
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await _pump(tester);

    expect(rs.canceled, contains(id));
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('deleting a deadline cancels its reminder', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    final rs = RecordingReminderScheduler();
    final id = await db.createAssignment(
      title: 'Essay',
      dueAt: DateTime.now().add(const Duration(days: 7)),
    );

    await tester.pumpWidget(_scope(db, rs));
    await _pump(tester);

    await tester.tap(find.textContaining('Essay'));
    await _pump(tester);
    await tester.tap(find.text('Delete'));
    await _pump(tester);

    expect(rs.canceled, contains(id));
    await tester.pump(const Duration(seconds: 5));
  });
}
