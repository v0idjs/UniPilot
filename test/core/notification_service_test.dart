import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/notifications/notification_service.dart';
import 'package:unipilot/core/notifications/reminder_scheduler.dart';

/// Exercises the real [NotificationService] (a singleton factory that
/// cannot be subclassed or mock-constructed). Plugin channel calls have
/// no host in unit tests, which is exactly what proves the service
/// contract: scheduling and cancelling are best-effort and never throw.
/// Id/offset math is covered by `reminder_scheduler_test.dart` and the
/// wiring by `deadline_reminders_test.dart`.
void main() {
  test('scheduleDeadline for a future due date never throws', () async {
    final service = NotificationService();

    await service.scheduleDeadline(
      assignmentId: 'abc',
      title: 'Essay',
      dueAt: DateTime.now().add(const Duration(days: 3)),
    );
  });

  test('scheduleDeadline for a past due date never throws', () async {
    final service = NotificationService();

    await service.scheduleDeadline(
      assignmentId: 'abc',
      title: 'Late',
      dueAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  });

  test('cancelDeadline never throws', () async {
    final service = NotificationService();

    await service.cancelDeadline('abc');
  });

  test('requestPermission returns without throwing', () async {
    final service = NotificationService();

    final granted = await service.requestPermission();
    expect(granted, isA<bool>());
  });

  test('reminder offsets are T-24h and T-1h', () {
    expect(reminderOffsets, hasLength(2));
    expect(reminderOffsets[0], const Duration(hours: 24));
    expect(reminderOffsets[1], const Duration(hours: 1));
  });
}
