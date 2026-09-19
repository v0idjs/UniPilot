/// Shared DB-layer validation for UniPilot.
///
/// Single source of truth used by both the real Drift database
/// (`AppDatabase`) and the widget-test fake (`FakeUniPilotDatabase`), so
/// the two can never diverge: add a guard here, never inline.
///
/// All failures throw [ValidationError].

/// Typed validation failure from the DB layer.
///
/// Extends [ArgumentError] so existing `throwsA(isA<ArgumentError>())`
/// expectations keep passing; the [field] identifies which input failed
/// so forms can eventually show per-field messages.
class ValidationError extends ArgumentError {
  final String field;
  ValidationError(this.field, String message) : super(message);

  @override
  String toString() => 'ValidationError($field): $message';
}

void validateCourse({required String code, required String name}) {
  if (code.trim().isEmpty) {
    throw ValidationError('code', 'Course code is required');
  }
  if (name.trim().isEmpty) {
    throw ValidationError('name', 'Course name is required');
  }
  if (code.trim().length > 60) {
    throw ValidationError('code', 'Course code too long (max 60)');
  }
  if (name.trim().length > 120) {
    throw ValidationError('name', 'Course name too long (max 120)');
  }
}

void validateSlot({
  required int dayOfWeek,
  required int startMinutes,
  required int endMinutes,
}) {
  if (dayOfWeek < 1 || dayOfWeek > 7) {
    throw ValidationError(
      'dayOfWeek',
      'dayOfWeek must be 1..7 (got $dayOfWeek)',
    );
  }
  if (startMinutes < 0 ||
      startMinutes >= 1440 ||
      endMinutes <= 0 ||
      endMinutes > 1440) {
    throw ValidationError('slot', 'Slot minutes must be within 0..1440');
  }
  if (endMinutes <= startMinutes) {
    throw ValidationError('slot', 'endMinutes must be after startMinutes');
  }
}

void validateAssignmentTitle(String title) {
  if (title.trim().isEmpty) {
    throw ValidationError('title', 'Title is required');
  }
  if (title.trim().length > 200) {
    throw ValidationError('title', 'Title too long (max 200)');
  }
}

void validateSemesterName(String name) {
  if (name.trim().isEmpty) {
    throw ValidationError('name', 'Semester name is required');
  }
  if (name.trim().length > 120) {
    throw ValidationError('name', 'Semester name too long (max 120)');
  }
}

void validateGrade({
  required String courseName,
  required String grade,
  required double credits,
}) {
  if (courseName.trim().isEmpty) {
    throw ValidationError('courseName', 'Course name is required');
  }
  if (grade.trim().isEmpty) {
    throw ValidationError('grade', 'Grade is required');
  }
  if (credits <= 0 || credits > 100) {
    throw ValidationError(
      'credits',
      'Credits must be > 0 and ≤ 100 (got $credits)',
    );
  }
}
