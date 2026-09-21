import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../utils/time.dart';
import 'reminder_scheduler.dart';

/// Plugin-backed [ReminderScheduler]: Android + Windows toasts.
///
/// Android uses inexact alarms (no exact-alarm permission needed).
/// Windows toasts need no runtime permission; on unpackaged (non-MSIX)
/// Windows builds `cancel` is a platform no-op.
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
    // Windows shows toasts via the plugin's C++/WinRT implementation.
    // appUserModelId + guid are required; the guid must be a bare
    // xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx string (no braces) or the
    // native side rejects it.
    const windowsSettings = WindowsInitializationSettings(
      appName: 'UniPilot',
      appUserModelId: 'com.unipilot.unipilot',
      guid: '8f4b2c1a-3d5e-4f70-9a1b-2c3d4e5f60718',
    );
    const settings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );
    try {
      await _plugin.initialize(settings: settings);
    } catch (e) {
      // Unsupported platform (e.g. Linux): reminders degrade silently.
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
        await _plugin.cancel(id: reminderNotificationId(assignmentId, i));
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
    const details = NotificationDetails(
      android: androidDetails,
      windows: WindowsNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id: id,
      title: 'Upcoming: $title',
      body: 'Due ${formatDueDate(dueAt.toLocal())}',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
