import 'dart:async';

import 'package:unipilot/core/db/app_database.dart';
import 'package:unipilot/core/db/database_api.dart';

/// Pure-Dart fake for widget tests.
///
/// Drift's real query streams schedule timers that never settle inside the
/// widget-test fake clock, hanging those tests until the 10-minute timeout.
/// This fake uses plain broadcast controllers plus an immediate snapshot, so
/// widget tests stay fast and hermetic with no native sqlite dependency.
class FakeUniPilotDatabase implements UniPilotDatabase {
  final _courses = <Course>[];
  final _coursesController = StreamController<List<Course>>.broadcast();

  final _assignments = <Assignment>[];
  final _assignmentsController = StreamController<List<Assignment>>.broadcast();

  final _semesters = <Semester>[];
  final _semestersController = StreamController<List<Semester>>.broadcast();

  int _seq = 0;
  bool _closed = false;

  void _checkOpen() {
    if (_closed) throw StateError('FakeUniPilotDatabase is closed');
  }

  @override
  Stream<List<Course>> watchCourses() async* {
    yield List<Course>.unmodifiable(_courses);
    yield* _coursesController.stream;
  }

  @override
  Future<int> createCourse({required String code, required String name}) async {
    _checkOpen();
    final now = DateTime.now();
    _courses.add(
      Course(
        id: 'course-${_seq++}',
        code: code,
        name: name,
        color: '232946',
        createdAt: now,
        updatedAt: now,
      ),
    );
    _coursesController.add(List<Course>.unmodifiable(_courses));
    return 1;
  }

  @override
  Stream<List<Assignment>> watchAssignments() async* {
    yield List<Assignment>.unmodifiable(_assignments);
    yield* _assignmentsController.stream;
  }

  @override
  Future<int> createAssignment({
    required String title,
    required DateTime dueAt,
  }) async {
    _checkOpen();
    final now = DateTime.now();
    _assignments.add(
      Assignment(
        id: 'assignment-${_seq++}',
        title: title,
        type: 'assignment',
        dueAt: dueAt,
        priority: 1,
        completed: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
    _assignmentsController.add(List<Assignment>.unmodifiable(_assignments));
    return 1;
  }

  @override
  Stream<List<Semester>> watchSemesters() async* {
    yield List<Semester>.unmodifiable(_semesters);
    yield* _semestersController.stream;
  }

  @override
  Future<int> createSemester({required String name}) async {
    _checkOpen();
    _semesters.add(
      Semester(
        id: 'semester-${_seq++}',
        name: name,
        gradingScaleId: 'gpa_4_0',
        createdAt: DateTime.now(),
      ),
    );
    _semestersController.add(List<Semester>.unmodifiable(_semesters));
    return 1;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _coursesController.close();
    await _assignmentsController.close();
    await _semestersController.close();
  }
}
