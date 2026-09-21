/// Coverage gate for CI: asserts >= 80% line coverage on non-generated code.
///
/// Reads an lcov report (default `coverage/lcov.info` from
/// `flutter test --coverage`), excludes `*.g.dart` generated files, and
/// exits non-zero below the threshold.
///
/// Usage: `dart tool/coverage_gate.dart [lcovPath] [minPercent]`
import 'dart:io';

Future<void> main(List<String> args) async {
  final path = args.isNotEmpty ? args[0] : 'coverage/lcov.info';
  final min = args.length > 1 ? double.parse(args[1]) : 80.0;
  final lines = await File(path).readAsLines();

  var file = '';
  var found = 0;
  var hit = 0;
  var totalFound = 0;
  var totalHit = 0;
  final rows = <String>[];

  void flush() {
    if (file.isEmpty || file.endsWith('.g.dart')) return;
    totalFound += found;
    totalHit += hit;
    final pct = found == 0 ? 100.0 : 100.0 * hit / found;
    rows.add('${pct.toStringAsFixed(1)}% $file');
  }

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      flush();
      file = line.substring(3);
      found = 0;
      hit = 0;
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3));
    }
  }
  flush();

  final pct = totalFound == 0 ? 0.0 : 100.0 * totalHit / totalFound;
  print(
    'coverage: ${pct.toStringAsFixed(1)}% '
    '($totalHit/$totalFound lines, generated code excluded, min $min%)',
  );
  if (pct < min) {
    print('BELOW GATE:');
    for (final r in rows) {
      print('  $r');
    }
    exit(1);
  }
}
