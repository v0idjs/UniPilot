import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';
import 'tables.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

@DriftDatabase(tables: [Courses, ScheduleEntries, Assignments, Semesters, CourseGrades, CampusRooms])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'unipilot_db'));

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

  Stream<List<Course>> watchCourses() =>
      (select(courses)..orderBy([(c) => OrderingTerm.asc(c.code)])).watch();

  Future<int> createCourse({required String code, required String name}) {
    return into(courses).insert(
      CoursesCompanion.insert(id: _uuid.v4(), code: code, name: name),
    );
  }

  Stream<List<Assignment>> watchAssignments() =>
      (select(assignments)..orderBy([(a) => OrderingTerm.asc(a.dueAt)])).watch();

  Future<int> createAssignment({required String title, required DateTime dueAt}) {
    return into(assignments).insert(
      AssignmentsCompanion.insert(id: _uuid.v4(), title: title, dueAt: dueAt),
    );
  }

  Stream<List<Semester>> watchSemesters() =>
      (select(semesters)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();

  Future<int> createSemester({required String name}) {
    return into(semesters).insert(
      SemestersCompanion.insert(id: _uuid.v4(), name: name),
    );
  }
}
