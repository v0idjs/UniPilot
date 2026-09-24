import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../utils/time.dart';
import 'reminder_scheduler.dart';

/// Plugin-backed [ReminderScheduler]: Android toasts.
///
/// Android uses inexact alarms (no exact-alarm permission needed).
/// Windows toasts are deferred: plugin 19.x (the first version with a
/// Windows implementation) crashes this project's AOT compiler
/// (see #16), so the plugin stays on 17.x — Android-only — until the
/// toolchain catches up. `scheduleDeadline`/`cancelDeadline` degrade
/// silently on unsupported platforms.
class NotificationService implements ReminderScheduler {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    try {
      await _plugin.initialize(settings);
    } catch (e) {
      // Unsupported platform: reminders degrade silently.
      debugPrint('Notifications unavailable on this platform: $e');
    }
    _initialized = true;
  }

  /// Android 13+ runtime permission. No-op (true) elsewhere.
  /// Never throws: an unregistered platform (e.g. unit tests) yields false.
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  @override
  Future<void> scheduleDeadline({
    required String assignmentId,
    required String title,
    required DateTime dueAt,
  }) async {
    try {
      await init();
      // Ask on Android 13+; elsewhere this is a no-op returning true.
      await requestPermission();
      for (var i = 0; i < reminderOffsets.length; i++) {
        await _scheduleOne(
          id: reminderNotificationId(assignmentId, i),
          title: title,
          dueAt: dueAt,
          offset: reminderOffsets[i],
        );
      }
    } catch (e) {
      debugPrint('Schedule deadline reminder failed: $e');
    }
  }

  @override
  Future<void> cancelDeadline(String assignmentId) async {
    try {
      await init();
      for (var i = 0; i < reminderOffsets.length; i++) {
        await _plugin.cancel(reminderNotificationId(assignmentId, i));
      }
    } catch (e) {
      debugPrint('Cancel deadline reminder failed: $e');
    }
  }

  Future<void> _scheduleOne({
    required int id,
    required String title,
    required DateTime dueAt,
    required Duration offset,
  }) async {
    final scheduled = tz.TZDateTime.from(dueAt.subtract(offset), tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;
    const androidDetails = AndroidNotificationDetails(
      'deadlines',
      'Deadlines',
      channelDescription: 'Assignment and exam reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.zonedSchedule(
      id,
      'Upcoming: $title',
      'Due ${formatDueDate(dueAt.toLocal())}',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
