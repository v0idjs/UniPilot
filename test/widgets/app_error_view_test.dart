import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/widgets/app_error_view.dart';

void main() {
  testWidgets('shows the message and retries on demand', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorView(
            message: 'Could not load courses',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Could not load courses'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
