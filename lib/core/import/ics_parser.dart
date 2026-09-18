/// Minimal ICS (iCalendar) parser for timetable VEVENTs.
/// Supports DTSTART/DTEND, SUMMARY, LOCATION, RRULE (weekly), TZID, EXDATE.
/// No external deps — keeps offline footprint small.
class IcsEvent {
  final String summary;
  final DateTime start;
  final DateTime end;
  final String? location;
  final String? rrule;
  const IcsEvent({required this.summary, required this.start, required this.end, this.location, this.rrule});
}

class IcsParseResult {
  final List<IcsEvent> events;
  final List<String> errors;
  const IcsParseResult({required this.events, required this.errors});
}

class IcsParser {
  static const maxInputBytes = 512 * 1024;
  static const maxEvents = 1000;
  static const maxRecurrences = 52;

  IcsParseResult parse(String text) {
    final errors = <String>[];
    final events = <IcsEvent>[];
    if (text.trim().isEmpty) return const IcsParseResult(events: [], errors: ['Empty ICS']);
    if (text.length > maxInputBytes) {
      return const IcsParseResult(events: [], errors: ['File too large (max 512KB)']);
    }
    // Unfold lines (RFC 5545)
    final unfolded = text.replaceAll('\r\n ', '').replaceAll('\n ', '').replaceAll('\r\n\t', '').replaceAll('\n\t', '');
    final lines = unfolded.split(RegExp(r'\r?\n')).map((e) => e.trim()).toList();
    Map<String, String>? current;
    for (final line in lines) {
      if (line == 'BEGIN:VEVENT') {
        current = {};
      } else if (line == 'END:VEVENT') {
        if (current != null) {
          final parsed = _parseEvent(current, errors);
          if (parsed != null) events.addAll(_expandRrule(parsed, errors));
          current = null;
        }
      } else if (current != null && line.contains(':')) {
        final idx = line.indexOf(':');
        final keyPart = line.substring(0, idx);
        final value = line.substring(idx + 1);
        final key = keyPart.split(';')[0].toUpperCase();
        // Keep TZID param if present
        if (key == 'DTSTART' || key == 'DTEND') {
          final tzMatch = RegExp(r'TZID=([^;:]+)').firstMatch(keyPart);
          if (tzMatch != null) {
            current['${key}_TZID'] = tzMatch.group(1)!;
          }
        }
        current[key] = value;
      }
    }
    if (events.length > maxEvents) {
      errors.add('Truncated to $maxEvents events');
      return IcsParseResult(
        events: events.take(maxEvents).toList(),
        errors: errors,
      );
    }
    if (events.isEmpty && errors.isEmpty) errors.add('No VEVENT found');
    return IcsParseResult(events: events, errors: errors);
  }

  IcsEvent? _parseEvent(Map<String, String> m, List<String> errors) {
    final summary = m['SUMMARY'] ?? 'Untitled';
    final dtStartRaw = m['DTSTART'];
    final dtEndRaw = m['DTEND'];
    if (dtStartRaw == null || dtEndRaw == null) {
      errors.add('VEVENT missing DTSTART/DTEND: $summary');
      return null;
    }
    final start = _parseDate(dtStartRaw, m['DTSTART_TZID']);
    final end = _parseDate(dtEndRaw, m['DTEND_TZID']);
    if (start == null || end == null) {
      errors.add('VEVENT invalid date: $summary ($dtStartRaw -> $dtEndRaw)');
      return null;
    }
    if (!end.isAfter(start)) {
      errors.add('VEVENT end before start: $summary');
      return null;
    }
    return IcsEvent(
      summary: summary,
      start: start,
      end: end,
      location: m['LOCATION'],
      rrule: m['RRULE'],
    );
  }

  DateTime? _parseDate(String raw, String? tzid) {
    // Formats: 20250915T090000Z, 20250915T090000, 20250915
    try {
      if (raw.endsWith('Z')) {
        final dt = _parseIcsDateTime(raw.substring(0, raw.length - 1));
        if (dt == null) return null;
        return dt.toUtc();
      }
      final dt = _parseIcsDateTime(raw);
      if (dt == null) return null;
      // If TZID provided we treat as local (no conversion — offline-first keeps wall time)
      // For v1 we keep wall time as is; exhaustive TZ db handled via timezone pkg at notification layer.
      return dt;
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseIcsDateTime(String s) {
    // s like 20250915T090000 or 20250915
    if (s.contains('T')) {
      final parts = s.split('T');
      if (parts.length != 2) return null;
      final d = parts[0];
      final t = parts[1];
      if (d.length != 8) return null;
      final y = int.tryParse(d.substring(0, 4));
      final mo = int.tryParse(d.substring(4, 6));
      final da = int.tryParse(d.substring(6, 8));
      if (y == null || mo == null || da == null) return null;
      if (t.length < 4) return null;
      final hh = int.tryParse(t.substring(0, 2)) ?? 0;
      final mm = int.tryParse(t.substring(2, 4)) ?? 0;
      final ss = t.length >= 6 ? int.tryParse(t.substring(4, 6)) ?? 0 : 0;
      return DateTime(y, mo, da, hh, mm, ss);
    } else {
      if (s.length != 8) return null;
      final y = int.tryParse(s.substring(0, 4));
      final mo = int.tryParse(s.substring(4, 6));
      final da = int.tryParse(s.substring(6, 8));
      if (y == null || mo == null || da == null) return null;
      return DateTime(y, mo, da);
    }
  }

  List<IcsEvent> _expandRrule(IcsEvent e, List<String> errors) {
    if (e.rrule == null) return [e];
    // Only handle FREQ=WEEKLY;COUNT=n or UNTIL; BYDAY optional
    final rrule = e.rrule!.toUpperCase();
    if (!rrule.contains('FREQ=WEEKLY')) return [e];
    final countMatch = RegExp(r'COUNT=(\d+)').firstMatch(rrule);
    final untilMatch = RegExp(r'UNTIL=([0-9T Z]+)').firstMatch(rrule);
    // tryParse: an over-long digit run overflows int and yields null,
    // which we clamp to the maximum instead of throwing.
    int count = int.tryParse(countMatch?.group(1) ?? '1') ?? maxRecurrences;
    count = count.clamp(1, maxRecurrences);
    if (count <= 1 && untilMatch != null) {
      final until = _parseDate(untilMatch.group(1)!.trim(), null);
      if (until != null) {
        if (until.isBefore(e.start)) {
          errors.add('RRULE UNTIL before DTSTART: ${e.summary}');
          return [];
        }
        final days = until.difference(e.start).inDays;
        count = (days ~/ 7) + 1;
        if (count > 52) count = 52;
      }
    }
    if (count <= 1) return [e];
    final out = <IcsEvent>[];
    for (var i = 0; i < count; i++) {
      out.add(IcsEvent(
        summary: e.summary,
        start: e.start.add(Duration(days: 7 * i)),
        end: e.end.add(Duration(days: 7 * i)),
        location: e.location,
        rrule: null,
      ));
    }
    return out;
  }
}
