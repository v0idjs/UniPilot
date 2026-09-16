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

  test('course can be edited and deleted', () async {
    final db = _memoryDb();
    addTearDown(db.close);

    await db.createCourse(code: 'CS101', name: 'Intro');
    final created = (await db.watchCourses().first).single;

    await db.updateCourse(id: created.id, code: 'CS102', name: 'Data');
    final updated = (await db.watchCourses().first).single;
    expect(updated.code, 'CS102');
    expect(updated.name, 'Data');

    await db.deleteCourse(created.id);
    expect(await db.watchCourses().first, isEmpty);
  });

  test('time slots are stored per course and streamed weekly', () async {
    final db = _memoryDb();
    addTearDown(db.close);

    await db.createCourse(code: 'CS101', name: 'Intro');
    final course = (await db.watchCourses().first).single;

    await db.createEntry(
      courseId: course.id,
      dayOfWeek: 1,
      startMinutes: 540,
      endMinutes: 600,
    );

    final entries = await db.watchEntries().first;
    expect(entries, hasLength(1));
    expect(entries.single.dayOfWeek, 1);

    await db.deleteEntry(entries.single.id);
    expect(await db.watchEntries().first, isEmpty);
  });

  test('deadline can be marked complete and deleted', () async {
    final db = _memoryDb();
    addTearDown(db.close);

    await db.createAssignment(
      title: 'Essay',
      dueAt: DateTime(2026, 10, 1, 12),
    );
    final created = (await db.watchAssignments().first).single;
    expect(created.completed, isFalse);

    await db.setAssignmentCompleted(id: created.id, completed: true);
    expect((await db.watchAssignments().first).single.completed, isTrue);

    await db.deleteAssignment(created.id);
    expect(await db.watchAssignments().first, isEmpty);
  });

  test('grades are stored per semester and semester deletes cascade', () async {
    final db = _memoryDb();
    addTearDown(db.close);

    await db.createSemester(name: 'Fall 2026');
    final semester = (await db.watchSemesters().first).single;

    await db.createGrade(
      semesterId: semester.id,
      courseName: 'Math',
      grade: 'A',
      credits: 3,
    );

    final grades = await db.watchGrades(semester.id).first;
    expect(grades.map((g) => g.courseName), contains('Math'));

    await db.deleteGrade(grades.single.id);
    expect(await db.watchGrades(semester.id).first, isEmpty);

    await db.deleteSemester(semester.id);
    expect(await db.watchSemesters().first, isEmpty);
  });
}
