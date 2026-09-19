import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/deadlines/deadline_list_screen.dart';
import 'package:unipilot/widgets/brand_logo.dart';

import '../../fakes/fake_database.dart';
import '../../fakes/fake_reminder_scheduler.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('deadline dialog carries the brand mark', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await db.createAssignment(
      title: 'Essay',
      dueAt: DateTime.now().add(const Duration(days: 7)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          reminderSchedulerProvider.overrideWithValue(NoopReminderScheduler()),
        ],
        child: const MaterialApp(home: DeadlineListScreen()),
      ),
    );
    await _pump(tester);

    await tester.tap(find.textContaining('Essay'));
    await _pump(tester);

    // The app bar carries its own mark; assert the one inside the dialog.
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(BrandLogo),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 5));
  });
}
