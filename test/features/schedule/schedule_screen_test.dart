import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/schedule/schedule_screen.dart';

import '../../fakes/fake_database.dart';

void main() {
  testWidgets('added course appears in schedule list', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ScheduleScreen()),
      ),
    );
    // Bounded pumps: the loading spinner animates forever, so
    // pumpAndSettle would never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Add Course'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(
      find.widgetWithText(TextField, 'Course code'),
      'CS101',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Course name'),
      'Intro',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('CS101'), findsWidgets);
    // Flush the confirmation snackbar timer before teardown.
    await tester.pump(const Duration(seconds: 5));
  });
}
