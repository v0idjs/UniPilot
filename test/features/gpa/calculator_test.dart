import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/features/gpa/calculator.dart';
import 'package:unipilot/features/gpa/grading_scales.dart';

void main() {
  group('calculateGpa 4.0 scale', () {
    final scale = Gpa40Scale();
    test('simple GPA', () {
      final courses = [
        CourseInput(grade: 'A', credits: 3),
        CourseInput(grade: 'B', credits: 3),
        CourseInput(grade: 'C', credits: 3),
      ];
      // (4.0*3 + 3.0*3 + 2.0*3)/9 = 3.0
      expect(calculateGpa(courses, scale), 3.0);
    });

    test('weighted credits', () {
      final courses = [
        CourseInput(grade: 'A', credits: 4),
        CourseInput(grade: 'B', credits: 2),
      ];
      // (4*4 + 3*2)/6 = 3.67
      expect(calculateGpa(courses, scale), 3.67);
    });

    test('pass/fail excluded', () {
      final courses = [
        CourseInput(grade: 'A', credits: 3),
        CourseInput(grade: 'P', credits: 3, isPassFail: true),
      ];
      expect(calculateGpa(courses, scale), 4.0);
    });

    test('empty returns 0', () {
      expect(calculateGpa([], scale), 0.0);
    });

    test('F grade', () {
      expect(calculateGpa([CourseInput(grade: 'F', credits: 3)], scale), 0.0);
    });

    test('honors bump', () {
      final courses = [CourseInput(grade: 'B', credits: 3, isHonors: true)];
      // B 3.0 +0.5 =3.5
      expect(calculateGpa(courses, scale), 3.5);
    });
  });

  group('grading scales', () {
    test('4.3 scale A+ =4.3', () {
      expect(Gpa43Scale().gradeToPoints('A+'), 4.3);
    });
    test('5.0 scale', () {
      expect(Gpa50Scale().gradeToPoints('A'), 5.0);
    });
    test('percentage scale', () {
      final s = PercentageScale();
      expect(s.gradeToPoints('95'), 4.0);
      expect(s.gradeToPoints('82'), 3.3);
      expect(s.isValidGrade('105'), false);
    });
    test('custom scale', () {
      final s = CustomScale(id: 'custom_test', displayName: 'Test', mapping: {'A': 4.0, 'B': 3.0});
      expect(s.gradeToPoints('A'), 4.0);
      expect(s.isValidGrade('C'), false);
    });
  });

  test('cumulative GPA', () {
    final s1 = [CourseInput(grade: 'A', credits: 3), CourseInput(grade: 'B', credits: 3)];
    final s2 = [CourseInput(grade: 'C', credits: 3)];
    final result = calculateCumulative([s1, s2], [Gpa40Scale(), Gpa40Scale()]);
    // (4*3 +3*3 +2*3)/9 =3.0
    expect(result, 3.0);
  });

  test('whatIf', () {
    final existing = [CourseInput(grade: 'B', credits: 3)];
    final hypo = [CourseInput(grade: 'A', credits: 3)];
    expect(whatIfGpa(existing, hypo, Gpa40Scale()), 3.5);
  });
}
