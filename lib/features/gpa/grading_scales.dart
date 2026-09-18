/// Grading scale abstraction. Supports 4.0, 4.3, 5.0, percentage, custom.
abstract class GradingScale {
  String get id;
  String get displayName;
  double get maxPoints;
  double gradeToPoints(String grade);
  bool isValidGrade(String grade);
}

class Gpa40Scale implements GradingScale {
  @override
  String get id => 'gpa_4_0';
  @override
  String get displayName => '4.0 Scale';
  @override
  double get maxPoints => 4.0;
  static const _map = {
    'A+': 4.0, 'A': 4.0, 'A-': 3.7,
    'B+': 3.3, 'B': 3.0, 'B-': 2.7,
    'C+': 2.3, 'C': 2.0, 'C-': 1.7,
    'D+': 1.3, 'D': 1.0, 'D-': 0.7,
    'F': 0.0,
  };
  @override
  double gradeToPoints(String grade) {
    final key = grade.trim().toUpperCase();
    if (_map.containsKey(key)) return _map[key]!;
    throw ArgumentError('Invalid grade "$grade" for 4.0 scale');
  }

  @override
  bool isValidGrade(String grade) => _map.containsKey(grade.trim().toUpperCase());
}

class Gpa43Scale implements GradingScale {
  @override
  String get id => 'gpa_4_3';
  @override
  String get displayName => '4.3 Scale (A+ = 4.3)';
  @override
  double get maxPoints => 4.3;
  static const _map = {
    'A+': 4.3, 'A': 4.0, 'A-': 3.7,
    'B+': 3.3, 'B': 3.0, 'B-': 2.7,
    'C+': 2.3, 'C': 2.0, 'C-': 1.7,
    'D+': 1.3, 'D': 1.0, 'D-': 0.7,
    'F': 0.0,
  };
  @override
  double gradeToPoints(String grade) {
    final key = grade.trim().toUpperCase();
    if (_map.containsKey(key)) return _map[key]!;
    throw ArgumentError('Invalid grade "$grade" for 4.3 scale');
  }

  @override
  bool isValidGrade(String grade) => _map.containsKey(grade.trim().toUpperCase());
}

class Gpa50Scale implements GradingScale {
  @override
  String get id => 'gpa_5_0';
  @override
  String get displayName => '5.0 Scale';
  @override
  double get maxPoints => 5.0;
  static const _map = {
    'A+': 5.0, 'A': 5.0, 'A-': 4.5,
    'B+': 4.0, 'B': 3.5, 'B-': 3.0,
    'C+': 2.5, 'C': 2.0, 'C-': 1.5,
    'D': 1.0, 'F': 0.0,
  };
  @override
  double gradeToPoints(String grade) {
    final key = grade.trim().toUpperCase();
    if (_map.containsKey(key)) return _map[key]!;
    throw ArgumentError('Invalid grade "$grade" for 5.0 scale');
  }

  @override
  bool isValidGrade(String grade) => _map.containsKey(grade.trim().toUpperCase());
}

class PercentageScale implements GradingScale {
  @override
  String get id => 'percentage';
  @override
  String get displayName => 'Percentage (0-100 → 4.0)';
  @override
  double get maxPoints => 4.0;
  @override
  double gradeToPoints(String grade) {
    final v = double.tryParse(grade.trim().replaceAll('%', ''));
    if (v == null || v < 0 || v > 100) throw ArgumentError('Invalid percentage "$grade"');
    if (v >= 90) return 4.0;
    if (v >= 85) return 3.7;
    if (v >= 80) return 3.3;
    if (v >= 75) return 3.0;
    if (v >= 70) return 2.7;
    if (v >= 65) return 2.3;
    if (v >= 60) return 2.0;
    if (v >= 55) return 1.7;
    if (v >= 50) return 1.0;
    return 0.0;
  }

  @override
  bool isValidGrade(String grade) {
    final v = double.tryParse(grade.trim().replaceAll('%', ''));
    return v != null && v >= 0 && v <= 100;
  }
}

class CustomScale implements GradingScale {
  @override
  final String id;
  @override
  final String displayName;
  final Map<String, double> mapping; // uppercase grade -> points
  CustomScale({required this.id, required this.displayName, required Map<String, double> mapping})
      : mapping = {for (final e in mapping.entries) e.key.toUpperCase(): e.value};

  @override
  double get maxPoints => mapping.isEmpty
      ? 4.0
      : mapping.values.reduce((a, b) => a > b ? a : b);

  @override
  double gradeToPoints(String grade) {
    final key = grade.trim().toUpperCase();
    if (mapping.containsKey(key)) return mapping[key]!;
    throw ArgumentError('Invalid grade "$grade" for custom scale $displayName');
  }

  @override
  bool isValidGrade(String grade) => mapping.containsKey(grade.trim().toUpperCase());
}

GradingScale scaleById(String id, {Map<String, double>? customMap}) {
  switch (id) {
    case 'gpa_4_0':
      return Gpa40Scale();
    case 'gpa_4_3':
      return Gpa43Scale();
    case 'gpa_5_0':
      return Gpa50Scale();
    case 'percentage':
      return PercentageScale();
    default:
      if (id.startsWith('custom_') && customMap != null) {
        return CustomScale(id: id, displayName: 'Custom', mapping: customMap);
      }
      return Gpa40Scale();
  }
}
