import 'app_database.dart';

/// Persistence surface consumed by the UI.
///
/// Extracted so widget tests can substitute a pure-Dart fake: drift's
/// real query streams schedule timers that never settle inside the
/// widget-test fake clock, hanging those tests until the 10-minute timeout.
abstract class UniPilotDatabase {
  Stream<List<Course>> watchCourses();
  Future<int> createCourse({required String code, required String name});

  Stream<List<Assignment>> watchAssignments();
  Future<int> createAssignment({
    required String title,
    required DateTime dueAt,
  });

  Stream<List<Semester>> watchSemesters();
  Future<int> createSemester({required String name});

  Future<void> close();
}
