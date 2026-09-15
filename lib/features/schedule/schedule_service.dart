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
  final nowDay = now.weekday;
  final nowMinutes = now.hour * 60 + now.minute;
  // Build ordered list for next 7 days
  ScheduleSlot? best;
  int bestDistance = 1 << 30;
  for (final s in slots) {
    int dayDiff = s.dayOfWeek - nowDay;
    if (dayDiff < 0) dayDiff += 7;
    if (dayDiff == 0 && s.startMinutes <= nowMinutes) {
      // Today but already started/passed -> next week
      dayDiff = 7;
    }
    // For tomorrow etc., distance = dayDiff*1440 + (start - nowMinutes if today else start)
    int distance;
    if (dayDiff == 0) {
      distance = s.startMinutes - nowMinutes;
    } else {
      distance = dayDiff * 1440 + s.startMinutes;
      // subtract nowMinutes to keep relative
      distance -= nowMinutes;
    }
    if (distance < bestDistance) {
      bestDistance = distance;
      best = s;
    }
  }
  return best;
}

String generateId() => const Uuid().v4();
