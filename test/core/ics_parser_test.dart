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
}
