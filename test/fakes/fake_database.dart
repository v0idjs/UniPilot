import 'dart:async';

import 'package:unipilot/core/db/app_database.dart';
import 'package:unipilot/core/db/database_api.dart';
import 'package:unipilot/core/db/validation.dart';

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

  final _entries = <ScheduleEntry>[];
  final _entriesController = StreamController<List<ScheduleEntry>>.broadcast();

  final _grades = <CourseGrade>[];
  final _gradesController = StreamController<List<CourseGrade>>.broadcast();

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
    validateCourse(code: code, name: name);
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
  Future<void> updateCourse({
    required String id,
    required String code,
    required String name,
  }) async {
    _checkOpen();
    final i = _courses.indexWhere((c) => c.id == id);
    if (i < 0) throw StateError('course $id not found');
    final old = _courses[i];
    _courses[i] =
        old.copyWith(code: code, name: name, updatedAt: DateTime.now());
    _coursesController.add(List<Course>.unmodifiable(_courses));
  }

  @override
  Future<void> deleteCourse(String id) async {
    _checkOpen();
    _courses.removeWhere((c) => c.id == id);
    _entries.removeWhere((e) => e.courseId == id);
    _coursesController.add(List<Course>.unmodifiable(_courses));
    _entriesController.add(List<ScheduleEntry>.unmodifiable(_entries));
  }

  @override
  Stream<List<ScheduleEntry>> watchEntries() async* {
    yield List<ScheduleEntry>.unmodifiable(_entries);
    yield* _entriesController.stream;
  }

  @override
  Future<int> createEntry({
    required String courseId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  }) async {
    _checkOpen();
    validateSlot(
      dayOfWeek: dayOfWeek,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    _entries.add(
      ScheduleEntry(
        id: 'entry-${_seq++}',
        courseId: courseId,
        dayOfWeek: dayOfWeek,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        createdAt: DateTime.now(),
      ),
    );
    _entriesController.add(List<ScheduleEntry>.unmodifiable(_entries));
    return 1;
  }

  @override
  Future<void> deleteEntry(String id) async {
    _checkOpen();
    _entries.removeWhere((e) => e.id == id);
    _entriesController.add(List<ScheduleEntry>.unmodifiable(_entries));
  }

  @override
  Stream<List<Assignment>> watchAssignments() async* {
    yield List<Assignment>.unmodifiable(_assignments);
    yield* _assignmentsController.stream;
  }

  @override
  Future<String> createAssignment({
    required String title,
    required DateTime dueAt,
  }) async {
    _checkOpen();
    validateAssignmentTitle(title);
    final now = DateTime.now();
    final id = 'assignment-${_seq++}';
    _assignments.add(
      Assignment(
        id: id,
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
    return id;
  }

  @override
  Future<void> setAssignmentCompleted({
    required String id,
    required bool completed,
  }) async {
    _checkOpen();
    final i = _assignments.indexWhere((a) => a.id == id);
    if (i < 0) throw StateError('assignment $id not found');
    final old = _assignments[i];
    _assignments[i] = old.copyWith(
      completed: completed,
      updatedAt: DateTime.now(),
    );
    _assignmentsController.add(List<Assignment>.unmodifiable(_assignments));
  }

  @override
  Future<void> deleteAssignment(String id) async {
    _checkOpen();
    _assignments.removeWhere((a) => a.id == id);
    _assignmentsController.add(List<Assignment>.unmodifiable(_assignments));
  }

  @override
  Stream<List<Semester>> watchSemesters() async* {
    yield List<Semester>.unmodifiable(_semesters);
    yield* _semestersController.stream;
  }

  @override
  Future<int> createSemester({required String name}) async {
    _checkOpen();
    validateSemesterName(name);
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
  Future<void> deleteSemester(String id) async {
    _checkOpen();
    _semesters.removeWhere((s) => s.id == id);
    _grades.removeWhere((g) => g.semesterId == id);
    _semestersController.add(List<Semester>.unmodifiable(_semesters));
    _gradesController.add(List<CourseGrade>.unmodifiable(_grades));
  }

  @override
  Stream<List<CourseGrade>> watchGrades(String semesterId) async* {
    yield List<CourseGrade>.unmodifiable(
      _grades.where((g) => g.semesterId == semesterId).toList(),
    );
    yield* _gradesController.stream.map(
      (all) => List<CourseGrade>.unmodifiable(
        all.where((g) => g.semesterId == semesterId).toList(),
      ),
    );
  }

  @override
  Future<int> createGrade({
    required String semesterId,
    required String courseName,
    required String grade,
    required double credits,
  }) async {
    _checkOpen();
    validateGrade(courseName: courseName, grade: grade, credits: credits);
    _grades.add(
      CourseGrade(
        id: 'grade-${_seq++}',
        semesterId: semesterId,
        courseName: courseName,
        grade: grade,
        credits: credits,
        isPassFail: false,
        isHonors: false,
      ),
    );
    _gradesController.add(List<CourseGrade>.unmodifiable(_grades));
    return 1;
  }

  @override
  Future<void> deleteGrade(String id) async {
    _checkOpen();
    _grades.removeWhere((g) => g.id == id);
    _gradesController.add(List<CourseGrade>.unmodifiable(_grades));
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _coursesController.close();
    await _assignmentsController.close();
    await _semestersController.close();
    await _entriesController.close();
    await _gradesController.close();
  }
}
