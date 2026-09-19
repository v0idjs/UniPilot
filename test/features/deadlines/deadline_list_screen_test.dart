import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/deadlines/deadline_list_screen.dart';

import '../../fakes/fake_database.dart';
import '../../fakes/fake_reminder_scheduler.dart';

void main() {
  testWidgets('added deadline appears in deadlines list', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(NoopReminderScheduler()),
        ],
        child: const MaterialApp(home: DeadlineListScreen()),
      ),
    );
    // Bounded pumps: the loading spinner animates forever, so
    // pumpAndSettle would never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Add Deadline'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Essay',
    );
    // Use the fallback date path: the form defaults to a due date when
    // none is picked, so saving must still persist and render the item.
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Essay'), findsWidgets);
    // Flush the confirmation snackbar timer before teardown.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('default deadline pins to 23:59 end-of-day', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(NoopReminderScheduler()),
        ],
        child: const MaterialApp(home: DeadlineListScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Add Deadline'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Time picker stays disabled until a date is chosen.
    expect(find.text('Pick a date first'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Exam',
    );
    // Save without picking: the fallback path must pin 23:59, not midnight.
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final items = await db.watchAssignments().first;
    expect(items.single.dueAt.hour, 23);
    expect(items.single.dueAt.minute, 59);
    await tester.pump(const Duration(seconds: 5));
  });
}
