import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    try {
      await _plugin.initialize(settings);
    } catch (e) {
      // Windows/Linux: plugin may not be supported, ignore
      debugPrint('Notifications unavailable on this platform: $e');
    }
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  Future<void> scheduleDeadlineReminder({
    required int id,
    required String title,
    required DateTime dueAt,
    Duration offset = const Duration(hours: 24),
  }) async {
    await init();
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
      'Due ${dueAt.toLocal()}',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
