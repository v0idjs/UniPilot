import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/widgets/empty_state.dart';

void main() {
  testWidgets('shows title, subtitle and fires the action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.book,
            title: 'No courses yet',
            subtitle: 'Add your first course',
            actionLabel: 'Add course',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('No courses yet'), findsOneWidget);
    expect(find.text('Add your first course'), findsOneWidget);

    await tester.tap(find.text('Add course'));
    expect(tapped, isTrue);
  });

  testWidgets('omits the button when no action is given', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.book,
            title: 'Nothing here',
            subtitle: 'Empty',
          ),
        ),
      ),
    );

    expect(find.byType(FilledButton), findsNothing);
  });
}
