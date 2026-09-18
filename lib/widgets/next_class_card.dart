import 'dart:async';

import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/utils/time.dart';
import '../features/schedule/schedule_service.dart';

/// Branded hero card for the next class: indigo gradient, countdown,
/// course identity, and room chip. Falls back to a calm empty state.
///
/// Refreshes every 60s so the countdown never goes stale between
/// stream events.
class NextClassCard extends StatefulWidget {
  final ScheduleSlot? slot;
  const NextClassCard({super.key, this.slot});

  @override
  State<NextClassCard> createState() => _NextClassCardState();
}

class _NextClassCardState extends State<NextClassCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.slot != null) {
      _timer = Timer.periodic(const Duration(seconds: 60), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(NextClassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slot == null && widget.slot != null) {
      _timer ??= Timer.periodic(const Duration(seconds: 60), (_) {
        if (mounted) setState(() {});
      });
    } else if (oldWidget.slot != null && widget.slot == null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    if (slot == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.event_available, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No upcoming classes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ]),
        ),
      );
    }
    final countdown = formatCountdown(nextOccurrence(slot, DateTime.now()));
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
            '${slot.courseCode} — ${slot.courseName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
              '${formatMinutes(slot.startMinutes)} – ${formatMinutes(slot.endMinutes)}',
              style: TextStyle(color: onIndigo.withOpacity(0.9)),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.room,
              size: 16,
              color: onIndigo.withOpacity(0.85),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                slot.room ?? 'TBA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: onIndigo.withOpacity(0.9)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
