import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/gpa/gpa_screen.dart';

import '../../fakes/fake_database.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('tapping a semester shows grades and computed GPA',
      (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await db.createSemester(name: 'Fall 2026');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: GpaScreen()),
      ),
    );
    await _pump(tester);

    await tester.tap(find.textContaining('Fall 2026'));
    await _pump(tester);

    await tester.tap(find.text('Add grade'));
    await _pump(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Course'),
      'Math',
    );
    // Grade defaults to A on the 4.0 scale, so saving directly is enough.
    await tester.tap(find.text('Save grade'));
    await _pump(tester);
    await tester.pump(const Duration(seconds: 5));

    expect(find.textContaining('Math'), findsWidgets);
    expect(find.textContaining('4.0'), findsWidgets);
  });
}
