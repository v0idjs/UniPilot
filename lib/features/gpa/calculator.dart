import 'grading_scales.dart';

class CourseInput {
  final String grade;
  final double credits;
  final bool isPassFail;
  final bool isHonors;
  const CourseInput({required this.grade, this.credits = 3.0, this.isPassFail = false, this.isHonors = false});
}

double calculateGpa(List<CourseInput> courses, GradingScale scale) {
  if (courses.isEmpty) return 0.0;
  double totalPoints = 0;
  double totalCredits = 0;
  for (final c in courses) {
    if (c.isPassFail) continue; // pass/fail excluded from GPA
    if (c.credits <= 0) continue;
    // honors bump +0.5 capped at scale max
    double points = scale.gradeToPoints(c.grade);
    if (c.isHonors) points = (points + 0.5).clamp(0, 5.0);
    totalPoints += points * c.credits;
    totalCredits += c.credits;
  }
  if (totalCredits == 0) return 0.0;
  final gpa = totalPoints / totalCredits;
  // round to 2 decimals without floating noise
  return double.parse(gpa.toStringAsFixed(2));
}

double calculateCumulative(List<List<CourseInput>> semesters, List<GradingScale> scales) {
  if (semesters.isEmpty) return 0.0;
  final all = <CourseInput>[];
  // For cumulative we weight each semester's GPA correctly by credits, so just flatten with scale per semester?
  // Simpler: compute total points across all semesters.
  double totalPoints = 0;
  double totalCredits = 0;
  for (var i = 0; i < semesters.length; i++) {
    final scale = i < scales.length ? scales[i] : scales.isNotEmpty ? scales.last : Gpa40Scale();
    for (final c in semesters[i]) {
      if (c.isPassFail || c.credits <= 0) continue;
      double points = scale.gradeToPoints(c.grade);
      if (c.isHonors) points = (points + 0.5).clamp(0, 5.0);
      totalPoints += points * c.credits;
      totalCredits += c.credits;
    }
  }
  if (totalCredits == 0) return 0.0;
  return double.parse((totalPoints / totalCredits).toStringAsFixed(2));
}

/// What-if: add hypothetical courses to existing list and recalculate.
double whatIfGpa(List<CourseInput> existing, List<CourseInput> hypothetical, GradingScale scale) {
  return calculateGpa([...existing, ...hypothetical], scale);
}
