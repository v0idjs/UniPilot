import 'package:csv/csv.dart';

class CsvImportRow {
  final String courseCode;
  final String courseName;
  final int dayOfWeek; // 1-7
  final int startMinutes;
  final int endMinutes;
  final String? room;
  const CsvImportRow({
    required this.courseCode,
    required this.courseName,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
    this.room,
  });
}

class CsvParseResult {
  final List<CsvImportRow> rows;
  final List<String> errors;
  const CsvParseResult({required this.rows, required this.errors});
  bool get hasErrors => errors.isNotEmpty;
}

class TimetableCsvParser {
  static const _headerAliases = {
    'course': 'code',
    'subject': 'code',
    'module': 'code',
    'course_code': 'code',
    'code': 'code',
    'course_name': 'name',
    'name': 'name',
    'title': 'name',
    'day': 'day',
    'dayofweek': 'day',
    'weekday': 'day',
    'start': 'start',
    'start_time': 'start',
    'begin': 'start',
    'end': 'end',
    'end_time': 'end',
    'finish': 'end',
    'room': 'room',
    'location': 'room',
  };

  static const _dayMap = {
    'mon': 1, 'monday': 1, '1': 1,
    'tue': 2, 'tuesday': 2, '2': 2,
    'wed': 3, 'wednesday': 3, '3': 3,
    'thu': 4, 'thursday': 4, '4': 4,
    'fri': 5, 'friday': 5, '5': 5,
    'sat': 6, 'saturday': 6, '6': 6,
    'sun': 7, 'sunday': 7, '7': 7,
  };

  static const maxInputBytes = 512 * 1024;
  static const maxRows = 2000;

  CsvParseResult parse(String csvText) {
    final errors = <String>[];
    final rows = <CsvImportRow>[];
    if (csvText.trim().isEmpty) {
      return const CsvParseResult(rows: [], errors: ['Empty CSV']);
    }
    if (csvText.length > maxInputBytes) {
      return const CsvParseResult(rows: [], errors: ['File too large (max 512KB)']);
    }
    // Auto-detect delimiter: semicolon vs comma
    final delimiter = csvText.contains(';') && !csvText.contains(',') ? ';' : ',';
    // But if both present, count
    String effectiveDelimiter = delimiter;
    if (csvText.contains(';') && csvText.contains(',')) {
      final semi = ';'.allMatches(csvText).length;
      final comma = ','.allMatches(csvText).length;
      effectiveDelimiter = semi > comma ? ';' : ',';
    }
    List<List<dynamic>> table;
    try {
      table = const CsvToListConverter().convert(csvText, eol: '\n', fieldDelimiter: effectiveDelimiter);
      // Fallback if only one row detected but contains \r\n
      if (table.length == 1 && csvText.contains('\r\n')) {
        table = const CsvToListConverter().convert(csvText, eol: '\r\n', fieldDelimiter: effectiveDelimiter);
      }
    } catch (e) {
      return CsvParseResult(rows: [], errors: ['CSV parse error: $e']);
    }
    if (table.isEmpty) return const CsvParseResult(rows: [], errors: ['No rows found']);
    // Also handle if csv lib treated whole file as one row due to delimiter mismatch -> retry with other delimiter
    if (table.length >= 2 && table[0].length == 1) {
      final alt = effectiveDelimiter == ',' ? ';' : ',';
      try {
        final altTable = const CsvToListConverter().convert(csvText, fieldDelimiter: alt);
        if (altTable.isNotEmpty && altTable[0].length > table[0].length) {
          table = altTable;
        }
      } catch (_) {}
    }
    final header = table[0].map((e) => e.toString().trim().toLowerCase().replaceAll(' ', '_')).toList();
    final colIndex = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final normalized = _headerAliases[header[i]] ?? header[i];
      colIndex[normalized] = i;
    }
    if (!colIndex.containsKey('code') || !colIndex.containsKey('day') || !colIndex.containsKey('start') || !colIndex.containsKey('end')) {
      errors.add('Missing required columns. Need: code, day, start, end. Found: ${header.join(', ')}');
      return CsvParseResult(rows: [], errors: errors);
    }
    var lastRow = table.length;
    if (table.length - 1 > maxRows) {
      errors.add('Truncated to $maxRows rows');
      lastRow = maxRows + 1; // header plus cap
    }
    for (var r = 1; r < lastRow; r++) {
      final row = table[r];
      if (row.every((e) => e.toString().trim().isEmpty)) continue;
      try {
        String getCol(String key) {
          final idx = colIndex[key]!;
          if (idx >= row.length) return '';
          return row[idx].toString().trim();
        }
        final code = getCol('code');
        final name = colIndex.containsKey('name') ? getCol('name') : code;
        final dayRaw = getCol('day').toLowerCase();
        final startRaw = getCol('start');
        final endRaw = getCol('end');
        final room = colIndex.containsKey('room') ? getCol('room') : null;
        if (code.isEmpty) {
          errors.add('Row ${r + 1}: missing course code');
          continue;
        }
        final day = _dayMap[dayRaw] ?? int.tryParse(dayRaw);
        if (day == null || day < 1 || day > 7) {
          errors.add('Row ${r + 1}: invalid day "$dayRaw"');
          continue;
        }
        final start = _parseTime(startRaw);
        final end = _parseTime(endRaw);
        if (start == null) {
          errors.add('Row ${r + 1}: invalid start time "$startRaw"');
          continue;
        }
        if (end == null) {
          errors.add('Row ${r + 1}: invalid end time "$endRaw"');
          continue;
        }
        if (end <= start) {
          errors.add('Row ${r + 1}: end time must be after start');
          continue;
        }
        rows.add(CsvImportRow(
          courseCode: code,
          courseName: name.isEmpty ? code : name,
          dayOfWeek: day,
          startMinutes: start,
          endMinutes: end,
          room: room?.isEmpty == true ? null : room,
        ));
      } catch (e) {
        errors.add('Row ${r + 1}: $e');
      }
    }
    return CsvParseResult(rows: rows, errors: errors);
  }

  int? _parseTime(String s) {
    s = s.trim();
    if (s.isEmpty) return null;
    // Accept HH:MM, H:MM, HH.MM, HHMM
    if (s.contains(':')) {
      final parts = s.split(':');
      if (parts.length != 2) return null;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) return null;
      if (h < 0 || h > 23 || m < 0 || m > 59) return null;
      return h * 60 + m;
    }
    if (s.contains('.')) {
      final parts = s.split('.');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h == null || m == null) return null;
        return h * 60 + m;
      }
    }
    // HHMM like 0930
    if (RegExp(r'^\d{3,4}$').hasMatch(s)) {
      final padded = s.padLeft(4, '0');
      final h = int.tryParse(padded.substring(0, 2));
      final m = int.tryParse(padded.substring(2, 4));
      if (h == null || m == null) return null;
      if (h > 23 || m > 59) return null;
      return h * 60 + m;
    }
    return null;
  }
}
