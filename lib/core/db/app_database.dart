import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'database_api.dart';
import 'tables.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'unipilot_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Courses, ScheduleEntries, Assignments, Semesters, CourseGrades, CampusRooms])
class AppDatabase extends _$AppDatabase implements UniPilotDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // future migrations
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  @override
  Stream<List<Course>> watchCourses() =>
      (select(courses)..orderBy([(c) => OrderingTerm.asc(c.code)])).watch();

  @override
  Future<int> createCourse({required String code, required String name}) {
    return into(courses).insert(
      CoursesCompanion.insert(id: _uuid.v4(), code: code, name: name),
    );
  }

  @override
  Future<void> updateCourse({
    required String id,
    required String code,
    required String name,
  }) async {
    await (update(courses)..where((c) => c.id.equals(id))).write(
      CoursesCompanion(
        code: Value(code),
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteCourse(String id) async {
    await (delete(courses)..where((c) => c.id.equals(id))).go();
  }

  @override
  Stream<List<ScheduleEntry>> watchEntries() =>
      (select(scheduleEntries)
            ..orderBy([
              (e) => OrderingTerm.asc(e.dayOfWeek),
              (e) => OrderingTerm.asc(e.startMinutes),
            ]))
          .watch();

  @override
  Future<int> createEntry({
    required String courseId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  }) {
    return into(scheduleEntries).insert(
      ScheduleEntriesCompanion.insert(
        id: _uuid.v4(),
        courseId: courseId,
        dayOfWeek: dayOfWeek,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
      ),
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    await (delete(scheduleEntries)..where((e) => e.id.equals(id))).go();
  }

  @override
  Stream<List<Assignment>> watchAssignments() =>
      (select(assignments)..orderBy([(a) => OrderingTerm.asc(a.dueAt)])).watch();

  @override
  Future<int> createAssignment({required String title, required DateTime dueAt}) {
    return into(assignments).insert(
      AssignmentsCompanion.insert(id: _uuid.v4(), title: title, dueAt: dueAt),
    );
  }

  @override
  Future<void> setAssignmentCompleted({
    required String id,
    required bool completed,
  }) async {
    await (update(assignments)..where((a) => a.id.equals(id))).write(
      AssignmentsCompanion(
        completed: Value(completed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await (delete(assignments)..where((a) => a.id.equals(id))).go();
  }

  @override
  Stream<List<Semester>> watchSemesters() =>
      (select(semesters)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();

  @override
  Future<int> createSemester({required String name}) {
    return into(semesters).insert(
      SemestersCompanion.insert(id: _uuid.v4(), name: name),
    );
  }

  @override
  Future<void> deleteSemester(String id) async {
    await (delete(semesters)..where((s) => s.id.equals(id))).go();
  }

  @override
  Stream<List<CourseGrade>> watchGrades(String semesterId) =>
      (select(courseGrades)
            ..where((g) => g.semesterId.equals(semesterId))
            ..orderBy([(g) => OrderingTerm.asc(g.courseName)]))
          .watch();

  @override
  Future<int> createGrade({
    required String semesterId,
    required String courseName,
    required String grade,
    required double credits,
  }) {
    return into(courseGrades).insert(
      CourseGradesCompanion.insert(
        id: _uuid.v4(),
        semesterId: semesterId,
        courseName: courseName,
        grade: grade,
        credits: Value(credits),
      ),
    );
  }

  @override
  Future<void> deleteGrade(String id) async {
    await (delete(courseGrades)..where((g) => g.id.equals(id))).go();
  }
}
