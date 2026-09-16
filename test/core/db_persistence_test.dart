import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/app_database.dart';

AppDatabase _memoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  test('saved course is persisted and streamed to schedule', () async {
    final db = _memoryDb();
    addTearDown(db.close);

    await db.createCourse(code: 'CS101', name: 'Intro');

    final courses = await db.watchCourses().first;
    expect(courses.map((c) => c.code), contains('CS101'));
    expect(courses.map((c) => c.name), contains('Intro'));
  });

  test('saved deadline is persisted and streamed to deadlines', () async {
    final db = _memoryDb();
    addTearDown(db.close);

    final due = DateTime(2026, 10, 1, 12);
    await db.createAssignment(title: 'Essay', dueAt: due);

    final items = await db.watchAssignments().first;
    expect(items.map((a) => a.title), contains('Essay'));
  });

  test('saved semester is persisted and streamed to GPA', () async {
    final db = _memoryDb();
    addTearDown(db.close);

    await db.createSemester(name: 'Fall 2026');

    final semesters = await db.watchSemesters().first;
    expect(semesters.map((s) => s.name), contains('Fall 2026'));
  });
}
