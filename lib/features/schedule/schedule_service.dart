import 'package:unipilot/core/db/app_database.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/time.dart';

class ScheduleSlot {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseName;
  final int dayOfWeek; // 1-7
  final int startMinutes;
  final int endMinutes;
  final String? room;
  const ScheduleSlot({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
    this.room,
  });
}

class Conflict {
  final ScheduleSlot a;
  final ScheduleSlot b;
  const Conflict(this.a, this.b);
}

List<Conflict> detectConflicts(List<ScheduleSlot> slots) {
  final conflicts = <Conflict>[];
  for (var i = 0; i < slots.length; i++) {
    for (var j = i + 1; j < slots.length; j++) {
      if (slots[i].dayOfWeek != slots[j].dayOfWeek) continue;
      if (isOverlapping(slots[i].startMinutes, slots[i].endMinutes, slots[j].startMinutes, slots[j].endMinutes)) {
        conflicts.add(Conflict(slots[i], slots[j]));
      }
    }
  }
  return conflicts;
}

/// Find next class from now.
ScheduleSlot? nextClass(List<ScheduleSlot> slots, DateTime now) {
  if (slots.isEmpty) return null;
  ScheduleSlot? best;
  int bestDistance = 1 << 30;
  for (final s in slots) {
    final distance =
        nextOccurrence(s, now).difference(now).inMinutes;
    if (distance < bestDistance) {
      bestDistance = distance;
      best = s;
    }
  }
  return best;
}

/// Next wall-clock occurrence of a weekly slot after [now].
/// Slots already started today roll to the same weekday next week.
DateTime nextOccurrence(ScheduleSlot slot, DateTime now) {
  var dayDiff = slot.dayOfWeek - now.weekday;
  if (dayDiff < 0) dayDiff += 7;
  final nowMinutes = now.hour * 60 + now.minute;
  if (dayDiff == 0 && slot.startMinutes <= nowMinutes) dayDiff = 7;
  final base =
      DateTime(now.year, now.month, now.day).add(Duration(days: dayDiff));
  return DateTime(
    base.year,
    base.month,
    base.day,
    slot.startMinutes ~/ 60,
    slot.startMinutes % 60,
  );
}

/// Map drift rows to UI slots, skipping orphan entries whose course
/// was deleted but whose FK row has not cascaded yet.
List<ScheduleSlot> toSlots(List<Course> courses, List<ScheduleEntry> entries) {
  final byId = {for (final c in courses) c.id: c};
  final slots = <ScheduleSlot>[];
  for (final e in entries) {
    final c = byId[e.courseId];
    if (c == null) continue;
    slots.add(
      ScheduleSlot(
        id: e.id,
        courseId: e.courseId,
        courseCode: c.code,
        courseName: c.name,
        dayOfWeek: e.dayOfWeek,
        startMinutes: e.startMinutes,
        endMinutes: e.endMinutes,
        room: e.room,
      ),
    );
  }
  return slots;
}

String generateId() => const Uuid().v4();
