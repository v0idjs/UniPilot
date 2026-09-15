import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/features/schedule/schedule_service.dart';

void main() {
  ScheduleSlot slot(String id, int day, int start, int end) => ScheduleSlot(
        id: id,
        courseId: 'c-$id',
        courseCode: 'CS$id',
        courseName: 'Course $id',
        dayOfWeek: day,
        startMinutes: start,
        endMinutes: end,
      );

  test('detectConflicts finds overlap same day', () {
    final a = slot('1', 1, 540, 630);
    final b = slot('2', 1, 600, 660);
    final c = slot('3', 2, 540, 630);
    final conflicts = detectConflicts([a, b, c]);
    expect(conflicts.length, 1);
    expect(conflicts[0].a.id, '1');
  });

  test('detectConflicts no conflict different day', () {
    final a = slot('1', 1, 540, 630);
    final b = slot('2', 2, 540, 630);
    expect(detectConflicts([a, b]), isEmpty);
  });

  test('nextClass finds same day future', () {
    // Monday 10:00, slots: Mon 09:00, Mon 11:00, Tue 09:00
    final slots = [slot('1', 1, 540, 600), slot('2', 1, 660, 720), slot('3', 2, 540, 600)];
    final now = DateTime(2025, 9, 15, 10, 0); // 2025-09-15 is Mon
    final next = nextClass(slots, now);
    expect(next?.id, '2');
  });

  test('nextClass wraps to next week', () {
    final slots = [slot('1', 1, 540, 600)]; // Mon 09:00
    final now = DateTime(2025, 9, 15, 12, 0); // Mon 12:00 after class
    final next = nextClass(slots, now);
    expect(next?.id, '1'); // next week
  });

  test('nextClass empty returns null', () {
    expect(nextClass([], DateTime.now()), isNull);
  });

  test('nextClass picks earliest next day', () {
    final slots = [slot('1', 3, 540, 600), slot('2', 2, 540, 600)]; // Wed, Tue
    final now = DateTime(2025, 9, 15, 10, 0); // Mon
    final next = nextClass(slots, now);
    expect(next?.id, '2'); // Tue is sooner than Wed
  });
}
