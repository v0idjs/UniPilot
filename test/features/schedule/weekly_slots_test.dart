import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/schedule/schedule_screen.dart';

import '../../fakes/fake_database.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('adding a time slot renders it in the weekly section',
      (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await db.createCourse(code: 'CS101', name: 'Intro');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ScheduleScreen()),
      ),
    );
    await _pump(tester);

    await tester.tap(find.textContaining('CS101'));
    await _pump(tester);

    await tester.tap(find.text('Add time slot'));
    await _pump(tester);

    // Defaults cover Monday 09:00-10:00, so saving directly is enough.
    await tester.tap(find.text('Save slot'));
    await _pump(tester);
    await tester.pump(const Duration(seconds: 5));

    expect(find.textContaining('Monday'), findsWidgets);
    expect(find.textContaining('09:00'), findsWidgets);
  });
}
