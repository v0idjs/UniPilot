import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/utils/time.dart';

void main() {
  test('formatMinutes', () {
    expect(formatMinutes(0), '00:00');
    expect(formatMinutes(540), '09:00');
    expect(formatMinutes(1439), '23:59');
  });

  test('formatCountdown future', () {
    final now = DateTime(2025, 9, 15, 10, 0);
    expect(formatCountdown(now.add(const Duration(minutes: 30)), now: now), '30m left');
    expect(formatCountdown(now.add(const Duration(hours: 2, minutes: 15)), now: now), '2h 15m left');
    expect(formatCountdown(now.add(const Duration(days: 3, hours: 2)), now: now), '3d 2h left');
    expect(formatCountdown(now.add(const Duration(days: 2)), now: now), '2d left');
  });

  test('formatCountdown overdue', () {
    final now = DateTime(2025, 9, 15, 10, 0);
    final due = now.subtract(const Duration(hours: 2));
    expect(formatCountdown(due, now: now), contains('Overdue'));
  });

  test('isOverlapping', () {
    expect(isOverlapping(540, 630, 600, 660), true);
    expect(isOverlapping(540, 600, 600, 660), false);
    expect(isOverlapping(540, 660, 600, 630), true);
  });
}
