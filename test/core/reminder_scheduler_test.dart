import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/notifications/reminder_scheduler.dart';

void main() {
  test('reminder ids are deterministic across calls', () {
    expect(
      reminderNotificationId('abc-123', 0),
      reminderNotificationId('abc-123', 0),
    );
    expect(
      reminderNotificationId('abc-123', 1),
      reminderNotificationId('abc-123', 1),
    );
  });

  test('each offset gets a distinct slot', () {
    final ids = [
      for (var i = 0; i < reminderOffsets.length; i++)
        reminderNotificationId('assignment-1', i),
    ];
    expect(ids.toSet(), hasLength(reminderOffsets.length));
    // Slots for one assignment are adjacent: base + offset index.
    expect(ids[1], ids[0] + 1);
  });

  test('different assignments map to different bases', () {
    expect(
      reminderBaseId('assignment-1') != reminderBaseId('assignment-2'),
      isTrue,
    );
  });

  test('ids are non-negative 31-bit ints (plugin-safe)', () {
    for (final id in ['a', 'assignment-99', 'x' * 200, ' Exams! 09:00 ']) {
      final base = reminderBaseId(id);
      expect(base >= 0, isTrue, reason: 'base for "$id"');
      expect(base < (1 << 31), isTrue, reason: 'base for "$id"');
    }
  });

  test('two offsets are configured (T-24h, T-1h)', () {
    expect(reminderOffsets, hasLength(2));
    expect(reminderOffsets[0], const Duration(hours: 24));
    expect(reminderOffsets[1], const Duration(hours: 1));
  });
}
