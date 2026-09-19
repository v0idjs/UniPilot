/// Reminder scheduling contract for deadline notifications.
///
/// Split from the plugin implementation so widgets depend on this
/// interface (via `reminderSchedulerProvider`) and tests can inject a
/// recording fake without touching platform channels.
abstract class ReminderScheduler {
  /// Schedule T-24h and T-1h reminders for a deadline. No-op for past
  /// due dates. Must never throw — notification failures must not break
  /// saving deadlines.
  Future<void> scheduleDeadline({
    required String assignmentId,
    required String title,
    required DateTime dueAt,
  });

  /// Cancel all reminders for a deadline (on delete or completion).
  /// Must never throw.
  Future<void> cancelDeadline(String assignmentId);
}

/// Reminder lead times before the due date.
const reminderOffsets = [Duration(hours: 24), Duration(hours: 1)];

/// Stable notification ids for an assignment: one slot per offset.
///
/// Derived deterministically from the assignment id (hand-rolled fold,
/// NOT `String.hashCode`, which is not stable across restarts —
/// scheduled ids must still match their cancellations after a reboot).
int reminderBaseId(String assignmentId) {
  var h = 0;
  for (final c in assignmentId.codeUnits) {
    h = ((h * 31) + c) & 0x0fffffff;
  }
  return h * reminderOffsets.length;
}

/// Concrete notification id for [assignmentId] at [offsetIndex].
int reminderNotificationId(String assignmentId, int offsetIndex) =>
    reminderBaseId(assignmentId) + offsetIndex;
