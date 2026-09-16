import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/deadlines/deadline_list_screen.dart';

import '../../fakes/fake_database.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('checking a deadline marks it complete', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await db.createAssignment(
      title: 'Essay',
      dueAt: DateTime.now().add(const Duration(days: 7)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: DeadlineListScreen()),
      ),
    );
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await _pump(tester);
    await tester.pump(const Duration(seconds: 5));

    expect(find.textContaining('Completed'), findsOneWidget);
  });

  testWidgets('tapping a deadline opens details with delete',
      (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await db.createAssignment(
      title: 'Essay',
      dueAt: DateTime.now().add(const Duration(days: 7)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: DeadlineListScreen()),
      ),
    );
    await _pump(tester);

    await tester.tap(find.textContaining('Essay'));
    await _pump(tester);

    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await _pump(tester);
    await tester.pump(const Duration(seconds: 5));

    expect(find.textContaining('Essay'), findsNothing);
  });
}
