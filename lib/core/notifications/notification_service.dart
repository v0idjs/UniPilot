import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../utils/time.dart';
import 'reminder_scheduler.dart';

/// Plugin-backed [ReminderScheduler]: Android + Windows toasts.
///
/// Android uses inexact alarms (no exact-alarm permission needed).
/// Windows toasts need no runtime permission; note that on unpackaged
/// (non-MSIX) Windows builds `cancel` is a platform no-op.
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
    // appUserModelId + guid are required by the plugin (19.x) to register
    // the toast activator; both are fixed app constants.
    // (Non-const: keeps compiling whether or not the settings
    // constructors are const in the resolved plugin version.)
    final windowsSettings = WindowsInitializationSettings(
      appName: 'UniPilot',
      appUserModelId: 'com.unipilot.unipilot',
      guid: '{8F4B2C1A-3D5E-4F70-9A1B-2C3D4E5F60718}',
    );
    final settings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );
    try {
      await _plugin.initialize(settings);
    } catch (e) {
      // Unsupported platform (e.g. Linux): reminders degrade silently.
      debugPrint('Notifications unavailable on this platform: $e');
    }
    _initialized = true;
  }

  /// Android 13+ runtime permission. No-op (true) elsewhere.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
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
    final details = NotificationDetails(
      android: androidDetails,
      windows: WindowsNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id,
      'Upcoming: $title',
      'Due ${formatDueDate(dueAt.toLocal())}',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
