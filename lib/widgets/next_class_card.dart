import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/utils/time.dart';
import '../features/schedule/schedule_service.dart';

/// Branded hero card for the next class: indigo gradient, countdown,
/// course identity, and room chip. Falls back to a calm empty state.
class NextClassCard extends StatelessWidget {
  final ScheduleSlot? slot;
  const NextClassCard({super.key, this.slot});

  DateTime _nextDateTime(ScheduleSlot s, DateTime now) {
    var dayDiff = s.dayOfWeek - now.weekday;
    if (dayDiff < 0) dayDiff += 7;
    final startToday = s.startMinutes > now.hour * 60 + now.minute;
    if (dayDiff == 0 && !startToday) dayDiff = 7;
    final base = DateTime(now.year, now.month, now.day)
        .add(Duration(days: dayDiff));
    return DateTime(
      base.year,
      base.month,
      base.day,
      s.startMinutes ~/ 60,
      s.startMinutes % 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (slot == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.event_available, size: 32),
            const SizedBox(width: 12),
            Text(
              'No upcoming classes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ]),
        ),
      );
    }
    final s = slot!;
    final countdown = formatCountdown(_nextDateTime(s, DateTime.now()));
    final onIndigo = Colors.white;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.indigoPrimary, AppColors.indigoLight],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.schedule, size: 20, color: AppColors.amberAccent),
            const SizedBox(width: 8),
            Text(
              'Next class',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: onIndigo.withOpacity(0.85),
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amberAccent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                countdown,
                semanticsLabel: 'Starts $countdown',
                style: const TextStyle(
                  color: AppColors.indigoPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            '${s.courseCode} — ${s.courseName}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onIndigo,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Row(children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: onIndigo.withOpacity(0.85),
            ),
            const SizedBox(width: 4),
            Text(
              '${formatMinutes(s.startMinutes)} – ${formatMinutes(s.endMinutes)}',
              style: TextStyle(color: onIndigo.withOpacity(0.9)),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.room,
              size: 16,
              color: onIndigo.withOpacity(0.85),
            ),
            const SizedBox(width: 4),
            Text(
              s.room ?? 'TBA',
              style: TextStyle(color: onIndigo.withOpacity(0.9)),
            ),
          ]),
        ]),
      ),
    );
  }
}
