import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/gpa/gpa_screen.dart';

import '../../fakes/fake_database.dart';

void main() {
  testWidgets('added semester appears in GPA screen', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: GpaScreen()),
      ),
    );
    // Bounded pumps: the loading spinner animates forever, so
    // pumpAndSettle would never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Add Semester'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(
      find.widgetWithText(TextField, 'Semester name'),
      'Fall 2026',
    );
    await tester.tap(find.text('Create'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Fall 2026'), findsWidgets);
    // Flush the confirmation snackbar timer before teardown.
    await tester.pump(const Duration(seconds: 5));
  });
}
