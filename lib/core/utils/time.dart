import 'package:intl/intl.dart';

String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

String formatCountdown(DateTime dueAt, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final diff = dueAt.difference(n);
  if (diff.isNegative) {
    final overdue = n.difference(dueAt);
    return 'Overdue by ${_humanDuration(overdue)}';
  }
  if (diff.inMinutes < 60) return '${diff.inMinutes}m left';
  if (diff.inHours < 24) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m == 0 ? '${h}h left' : '${h}h ${m}m left';
  }
  final d = diff.inDays;
  final h = diff.inHours % 24;
  return h == 0 ? '${d}d left' : '${d}d ${h}h left';
}

String _humanDuration(Duration d) {
  if (d.inDays >= 1) return '${d.inDays}d';
  if (d.inHours >= 1) return '${d.inHours}h';
  return '${d.inMinutes}m';
}

String formatDueDate(DateTime dueAt) {
  return DateFormat('EEE, MMM d • HH:mm').format(dueAt);
}

int dayOfWeekFromDateTime(DateTime dt) => dt.weekday; // 1=Mon ... 7=Sun

bool isOverlapping(int startA, int endA, int startB, int endB) {
  return startA < endB && startB < endA;
}
