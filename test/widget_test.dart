import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/app.dart';
import 'package:unipilot/core/db/app_database.dart';
import 'package:unipilot/core/db/providers.dart';

void main() {
  testWidgets('UniPilotApp builds', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      UniPilotApp(overrides: [dbProvider.overrideWithValue(db)]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Schedule'), findsWidgets);
  });
}
