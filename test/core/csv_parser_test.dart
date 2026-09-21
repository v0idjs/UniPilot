import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/import/csv_parser.dart';

void main() {
  final parser = TimetableCsvParser();

  test('parses valid CSV with header aliases', () {
    // Header aliases: code,name,day,start,end
    const csv2 = 'code,name,day,start,end\nCS101,Intro to CS,Mon,09:00,10:30';
    final r = parser.parse(csv2);
    expect(r.errors, isEmpty);
    expect(r.rows.length, 1);
    expect(r.rows[0].courseCode, 'CS101');
    expect(r.rows[0].dayOfWeek, 1);
    expect(r.rows[0].startMinutes, 540);
    expect(r.rows[0].endMinutes, 630);
  });

  test('handles semicolon delimiter and aliases', () {
    const csv = 'course;name;day;start;end\nCS101;Intro;Tue;11:00;12:30';
    final r = parser.parse(csv);
    expect(r.rows.length, 1);
    expect(r.rows[0].dayOfWeek, 2);
  });

  test('reports invalid day and time', () {
    const csv = 'code,name,day,start,end\nCS101,X,FunDay,09:00,10:30\nCS102,Y,Mon,25:00,10:30';
    final r = parser.parse(csv);
    expect(r.rows, isEmpty);
    expect(r.errors.length, 2);
  });

  test('handles empty CSV', () {
    final r = parser.parse('');
    expect(r.errors, isNotEmpty);
  });

  test('handles HHMM time format', () {
    const csv = 'code,day,start,end\nCS101,Mon,0930,1030';
    final r = parser.parse(csv);
    expect(r.rows[0].startMinutes, 570);
    expect(r.rows[0].endMinutes, 630);
  });

  test('detects missing required columns', () {
    const csv = 'code,name\nCS101,Intro';
    final r = parser.parse(csv);
    expect(r.errors.first, contains('Missing required columns'));
  });

  test('parses sample file content', () {
    const csv = 'code,name,day,start,end,room\nCS101,Intro to CS,Mon,09:00,10:30,A101\nMA201,Calculus II,Tue,11:00,12:30,B203';
    final r = parser.parse(csv);
    expect(r.rows.length, 2);
    expect(r.rows[1].room, 'B203');
  });

  test('rejects out-of-range dot times', () {
    const badHour = 'code,day,start,end\nCS101,Mon,25.00,26.00';
    final r1 = parser.parse(badHour);
    expect(r1.rows, isEmpty);
    expect(r1.errors, isNotEmpty);

    const badMin = 'code,day,start,end\nCS101,Mon,10.99,11.30';
    final r2 = parser.parse(badMin);
    expect(r2.rows, isEmpty);
    expect(r2.errors, isNotEmpty);
  });

  test('parses dot time format', () {
    const csv = 'code,day,start,end\nCS101,Mon,09.30,10.30';
    final r = parser.parse(csv);
    expect(r.errors, isEmpty);
    expect(r.rows[0].startMinutes, 570);
  });

  test('rejects oversize input', () {
    final big = 'A' * (512 * 1024 + 1);
    final r = parser.parse(big);
    expect(r.rows, isEmpty);
    expect(r.errors.any((e) => e.contains('too large')), isTrue);
  });

  test('truncates excessive rows', () {
    final buf = StringBuffer('code,name,day,start,end\n');
    for (var i = 0; i < 2500; i++) {
      buf.writeln('C$i,Course $i,Mon,09:00,10:00');
    }
    final r = parser.parse(buf.toString());
    expect(r.rows.length, 2000);
    expect(r.errors.any((e) => e.contains('Truncated')), isTrue);
  });
}
