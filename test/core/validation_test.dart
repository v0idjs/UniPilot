import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/db/app_database.dart';
import 'package:unipilot/core/db/database_api.dart';
import 'package:unipilot/core/db/validation.dart';

import '../fakes/fake_database.dart';

/// Locks the shared validation contract (#9, #10):
/// - failures are typed [ValidationError]s carrying the failing field;
/// - [ValidationError] stays an [ArgumentError] (backward compatible);
/// - real Drift DB and widget-test fake reject the same inputs the same way.
void main() {
  group('ValidationError type', () {
    test('is an ArgumentError (backward compatible)', () {
      final e = ValidationError('title', 'Title is required');
      expect(e, isA<ArgumentError>());
      expect(e.field, 'title');
      expect(e.toString(), contains('title'));
    });

    test('validators report the failing field', () {
      expect(
        () => validateCourse(code: '', name: 'X'),
        throwsA(
          isA<ValidationError>().having((e) => e.field, 'field', 'code'),
        ),
      );
      expect(
        () => validateSlot(dayOfWeek: 0, startMinutes: 0, endMinutes: 60),
        throwsA(
          isA<ValidationError>().having((e) => e.field, 'field', 'dayOfWeek'),
        ),
      );
      expect(
        () => validateAssignmentTitle(''),
        throwsA(
          isA<ValidationError>().having((e) => e.field, 'field', 'title'),
        ),
      );
      expect(
        () => validateSemesterName(''),
        throwsA(
          isA<ValidationError>().having((e) => e.field, 'field', 'name'),
        ),
      );
      expect(
        () => validateGrade(courseName: 'M', grade: 'A', credits: 0),
        throwsA(
          isA<ValidationError>().having((e) => e.field, 'field', 'credits'),
        ),
      );
    });
  });

  group('real DB and fake agree', () {
    test('empty course code throws ValidationError(field=code) in both',
        () async {
      final real = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(real.close);
      final fake = FakeUniPilotDatabase();
      addTearDown(fake.close);

      final dbs = <UniPilotDatabase>[real, fake];
      for (final db in dbs) {
        await expectLater(
          db.createCourse(code: '', name: 'Intro'),
          throwsA(
            isA<ValidationError>().having((e) => e.field, 'field', 'code'),
          ),
        );
      }
    });

    test('out-of-range slot throws ValidationError(field=dayOfWeek) in both',
        () async {
      final real = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(real.close);
      final fake = FakeUniPilotDatabase();
      addTearDown(fake.close);

      await real.createCourse(code: 'CS101', name: 'Intro');
      await fake.createCourse(code: 'CS101', name: 'Intro');
      final realCourseId = (await real.watchCourses().first).single.id;
      final fakeCourseId = (await fake.watchCourses().first).single.id;

      await expectLater(
        real.createEntry(
          courseId: realCourseId,
          dayOfWeek: 8,
          startMinutes: 540,
          endMinutes: 600,
        ),
        throwsA(
          isA<ValidationError>().having((e) => e.field, 'field', 'dayOfWeek'),
        ),
      );
      await expectLater(
        fake.createEntry(
          courseId: fakeCourseId,
          dayOfWeek: 8,
          startMinutes: 540,
          endMinutes: 600,
        ),
        throwsA(
          isA<ValidationError>().having((e) => e.field, 'field', 'dayOfWeek'),
        ),
      );
    });
  });
}
