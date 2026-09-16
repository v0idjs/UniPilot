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
  Stream<List<Assignment>> watchAssignments() =>
      (select(assignments)..orderBy([(a) => OrderingTerm.asc(a.dueAt)])).watch();

  @override
  Future<int> createAssignment({required String title, required DateTime dueAt}) {
    return into(assignments).insert(
      AssignmentsCompanion.insert(id: _uuid.v4(), title: title, dueAt: dueAt),
    );
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
}
