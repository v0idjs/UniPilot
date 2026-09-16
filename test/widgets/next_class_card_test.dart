import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/features/schedule/schedule_service.dart';
import 'package:unipilot/widgets/next_class_card.dart';

ScheduleSlot _slot(String? room) {
  final now = DateTime.now();
  var day = now.weekday;
  var start = now.hour * 60 + now.minute + 60;
  if (start + 60 >= 1440) {
    day = now.weekday % 7 + 1;
    start = 540;
  }
  return ScheduleSlot(
    id: '1',
    courseId: 'c1',
    courseCode: 'CS101',
    courseName: 'Intro',
    dayOfWeek: day,
    startMinutes: start,
    endMinutes: start + 60,
    room: room,
  );
}

void main() {
  testWidgets('hero shows next class with countdown and room', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NextClassCard(slot: _slot('A101')))),
    );

    expect(find.text('Next class'), findsOneWidget);
    expect(find.textContaining('CS101'), findsOneWidget);
    expect(find.textContaining('A101'), findsOneWidget);
    expect(find.textContaining('left'), findsOneWidget);
  });

  testWidgets('hero shows empty state without a slot', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextClassCard(slot: null))),
    );

    expect(find.text('No upcoming classes'), findsOneWidget);
  });
}
