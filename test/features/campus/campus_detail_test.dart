import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/features/campus/campus_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('tapping a campus room opens its details', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CampusScreen()));
    await _pump(tester);

    await tester.tap(find.textContaining('A101').first);
    await _pump(tester);

    expect(find.textContaining('Near main entrance'), findsOneWidget);
  });
}
