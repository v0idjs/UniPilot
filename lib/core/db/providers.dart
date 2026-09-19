import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifications/reminder_scheduler.dart';
import '../notifications/notification_service.dart';
import 'app_database.dart';
import 'database_api.dart';

final dbProvider = Provider<UniPilotDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    // close() is async; fire-and-forget is intentional here —
    // Riverpod disposers are synchronous.
    // ignore: discarded_futures
    db.close();
  });
  return db;
});

final coursesProvider = StreamProvider<List<Course>>((ref) {
  return ref.watch(dbProvider).watchCourses();
});

final assignmentsProvider = StreamProvider<List<Assignment>>((ref) {
  return ref.watch(dbProvider).watchAssignments();
});

/// Reminder scheduler (Android + Windows toasts). Override with a fake
/// in widget tests — never let tests touch platform channels.
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return NotificationService();
});

final semestersProvider = StreamProvider<List<Semester>>((ref) {
  return ref.watch(dbProvider).watchSemesters();
});

final entriesProvider = StreamProvider<List<ScheduleEntry>>((ref) {
  return ref.watch(dbProvider).watchEntries();
});

final gradesProvider =
    StreamProvider.family<List<CourseGrade>, String>((ref, semesterId) {
  return ref.watch(dbProvider).watchGrades(semesterId);
});
