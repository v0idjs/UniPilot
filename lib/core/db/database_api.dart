import 'app_database.dart';

/// Persistence surface consumed by the UI.
///
/// Extracted so widget tests can substitute a pure-Dart fake: drift's
/// real query streams schedule timers that never settle inside the
/// widget-test fake clock, hanging those tests until the 10-minute timeout.
abstract class UniPilotDatabase {
  Stream<List<Course>> watchCourses();
  Future<int> createCourse({required String code, required String name});
  Future<void> updateCourse({
    required String id,
    required String code,
    required String name,
  });
  Future<void> deleteCourse(String id);

  Stream<List<ScheduleEntry>> watchEntries();
  Future<int> createEntry({
    required String courseId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  });
  Future<void> deleteEntry(String id);

  Stream<List<Assignment>> watchAssignments();

  /// Creates the assignment and returns its new id (needed to tie
  /// scheduled reminders to the row).
  Future<String> createAssignment({
    required String title,
    required DateTime dueAt,
  });
  Future<void> setAssignmentCompleted({
    required String id,
    required bool completed,
  });
  Future<void> deleteAssignment(String id);

  Stream<List<Semester>> watchSemesters();
  Future<int> createSemester({required String name});
  Future<void> deleteSemester(String id);

  Stream<List<CourseGrade>> watchGrades(String semesterId);
  Future<int> createGrade({
    required String semesterId,
    required String courseName,
    required String grade,
    required double credits,
  });
  Future<void> deleteGrade(String id);

  Future<void> close();
}
