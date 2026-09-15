import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/app.dart';

void main() {
  testWidgets('UniPilotApp builds', (tester) async {
    await tester.pumpWidget(const UniPilotApp());
    expect(find.text('Schedule'), findsWidgets);
  });
}
