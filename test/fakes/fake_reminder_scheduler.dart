import 'package:unipilot/core/notifications/reminder_scheduler.dart';

/// No-op scheduler for widget tests that don't assert on reminders.
///
/// Keeps timezone init latency and platform channels out of unrelated
/// tests — always override `reminderSchedulerProvider` with this (or
/// [RecordingReminderScheduler]) instead of letting tests construct the
/// real `NotificationService`.
class NoopReminderScheduler implements ReminderScheduler {
  @override
  Future<void> scheduleDeadline({
    required String assignmentId,
    required String title,
    required DateTime dueAt,
  }) async {}

  @override
  Future<void> cancelDeadline(String assignmentId) async {}
}

/// Scheduler that records calls, for tests asserting on reminder wiring.
class RecordingReminderScheduler implements ReminderScheduler {
  final scheduled = <({String id, String title, DateTime dueAt})>[];
  final canceled = <String>[];

  @override
  Future<void> scheduleDeadline({
    required String assignmentId,
    required String title,
    required DateTime dueAt,
  }) async {
    scheduled.add((id: assignmentId, title: title, dueAt: dueAt));
  }

  @override
  Future<void> cancelDeadline(String assignmentId) async {
    canceled.add(assignmentId);
  }
}
