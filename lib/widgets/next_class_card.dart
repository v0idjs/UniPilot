import 'package:flutter/material.dart';
import '../core/utils/time.dart';
import '../features/schedule/schedule_service.dart';

class NextClassCard extends StatelessWidget {
  final ScheduleSlot? slot;
  const NextClassCard({super.key, this.slot});

  @override
  Widget build(BuildContext context) {
    if (slot == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.event_available, size: 32),
            const SizedBox(width: 12),
            Text('No upcoming classes', style: Theme.of(context).textTheme.titleMedium),
          ]),
        ),
      );
    }
    final s = slot!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.schedule, size: 20),
            const SizedBox(width: 8),
            Text('Next class', style: Theme.of(context).textTheme.labelLarge),
          ]),
          const SizedBox(height: 8),
          Text('${s.courseCode} — ${s.courseName}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('${formatMinutes(s.startMinutes)} – ${formatMinutes(s.endMinutes)} • ${s.room ?? 'TBA'}'),
        ]),
      ),
    );
  }
}
