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
  testWidgets('tapping a course opens details with delete', (tester) async {
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

    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await _pump(tester);
    await tester.pump(const Duration(seconds: 5));

    expect(find.textContaining('CS101'), findsNothing);
  });

  testWidgets('tapping a course allows editing code and name', (tester) async {
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

    await tester.tap(find.text('Edit'));
    await _pump(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Course code'),
      'CS102',
    );
    await tester.tap(find.text('Save changes'));
    await _pump(tester);
    await tester.pump(const Duration(seconds: 5));

    expect(find.textContaining('CS102'), findsWidgets);
  });
}
