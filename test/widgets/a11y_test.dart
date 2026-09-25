import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/providers.dart';
import 'package:unipilot/features/schedule/schedule_screen.dart';

import '../fakes/fake_database.dart';

/// Accessibility guards for #13: minimum tap targets and labels for
/// icon-only controls. Text scaling is covered in text_scaling_test.dart,
/// palette contrast in theme_contrast_test.dart.
void main() {
  Future<void> pumpSchedule(
    WidgetTester tester,
    FakeUniPilotDatabase db,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ScheduleScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('primary action meets the 48px minimum tap target',
      (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await pumpSchedule(tester, db);

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    final size = tester.getSize(fab);
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
  });

  testWidgets('every icon-only button exposes a tooltip for screen readers',
      (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    // Seed one entry so the delete control renders.
    final courseId = await db.createCourse(code: 'CS101', name: 'Intro');
    await db.createEntry(
      courseId: '$courseId',
      dayOfWeek: 1,
      startMinutes: 540,
      endMinutes: 600,
    );
    await pumpSchedule(tester, db);

    final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
    expect(buttons, isNotEmpty);
    for (final b in buttons) {
      expect(b.tooltip, isNotNull, reason: 'IconButton without tooltip');
      expect(b.tooltip, isNotEmpty, reason: 'IconButton with empty tooltip');
    }
  });

  testWidgets('brand logo exposes a semantic label', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await pumpSchedule(tester, db);

    final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
    final labels = [
      for (final s in semantics)
        if (s.properties.label != null) s.properties.label!,
    ];
    expect(labels, contains('UniPilot logo'));
  });
}
