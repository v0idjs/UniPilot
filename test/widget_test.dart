import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/app.dart';
import 'package:unipilot/core/db/providers.dart';

import 'fakes/fake_database.dart';

void main() {
  testWidgets('UniPilotApp builds', (tester) async {
    final db = FakeUniPilotDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      UniPilotApp(overrides: [dbProvider.overrideWithValue(db)]),
    );
    // Bounded pumps: loading spinners animate forever, so
    // pumpAndSettle would never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Schedule'), findsWidgets);
  });
}
