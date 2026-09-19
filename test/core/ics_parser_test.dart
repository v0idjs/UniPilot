import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/import/ics_parser.dart';

void main() {
  final parser = IcsParser();

  test('parses single VEVENT', () {
    const ics = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:CS101\nLOCATION:A101\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 1);
    expect(r.events[0].summary, 'CS101');
    expect(r.events[0].location, 'A101');
  });

  test('expands weekly RRULE', () {
    const ics = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:CS101\nRRULE:FREQ=WEEKLY;COUNT=3\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 3);
    expect(r.events[1].start.difference(r.events[0].start).inDays, 7);
  });

  test('handles TZID', () {
    const ics = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART;TZID=Europe/Berlin:20250915T090000\nDTEND;TZID=Europe/Berlin:20250915T103000\nSUMMARY:Test\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 1);
    expect(r.errors, isEmpty);
  });

  test('reports missing VEVENT', () {
    const ics = 'BEGIN:VCALENDAR\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.errors, isNotEmpty);
  });

  test('parses sample ICS', () {
    const ics = 'BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nUID:cs101@unipilot\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:CS101 Intro to CS\nLOCATION:A101\nRRULE:FREQ=WEEKLY;COUNT=12\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 12);
  });

  test('rejects oversize input', () {
    final big = 'A' * (512 * 1024 + 1);
    final r = parser.parse(big);
    expect(r.events, isEmpty);
    expect(r.errors.any((e) => e.contains('too large')), isTrue);
  });

  test('clamps huge COUNT instead of throwing', () {
    const ics = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:X\nRRULE:FREQ=WEEKLY;COUNT=99999999999999999999999\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 52);
  });

  test('warns when COUNT is truncated to 52', () {
    const ics = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:LongCourse\nRRULE:FREQ=WEEKLY;COUNT=100\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 52);
    expect(r.errors.any((e) => e.contains('truncated to 52')), isTrue);
  });

  test('warns when UNTIL range is truncated to 52', () {
    const ics = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:YearLong\nRRULE:FREQ=WEEKLY;UNTIL=20270915T090000\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 52);
    expect(r.errors.any((e) => e.contains('truncated to 52')), isTrue);
  });

  test('small COUNT produces no truncation warning', () {
    const ics = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:Short\nRRULE:FREQ=WEEKLY;COUNT=3\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events.length, 3);
    expect(r.errors, isEmpty);
  });

  test('UNTIL before DTSTART returns empty events plus error', () {
    const ics =
        'BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:CS101\nRRULE:FREQ=WEEKLY;UNTIL=20250901T090000\nEND:VEVENT\nEND:VCALENDAR';
    final r = parser.parse(ics);
    expect(r.events, isEmpty);
    expect(r.errors, isNotEmpty);
  });

  test('truncates runaway total events', () {
    final buf = StringBuffer('BEGIN:VCALENDAR\n');
    for (var i = 0; i < 30; i++) {
      buf.writeln('BEGIN:VEVENT\nDTSTART:20250915T090000\nDTEND:20250915T103000\nSUMMARY:C$i\nRRULE:FREQ=WEEKLY;COUNT=52\nEND:VEVENT');
    }
    buf.writeln('END:VCALENDAR');
    final r = parser.parse(buf.toString());
    expect(r.events.length, 1000);
    expect(r.errors.any((e) => e.contains('Truncated')), isTrue);
  });
}
