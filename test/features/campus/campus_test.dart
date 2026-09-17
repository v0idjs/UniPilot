import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/features/campus/campus_data.dart';

void main() {
  test('searchRooms filters by query', () {
    final res = searchRooms('library', campusRoomsSample);
    expect(res.length, 2);
  });
  test('searchRooms empty returns all', () {
    expect(searchRooms('', campusRoomsSample).length, campusRoomsSample.length);
  });
  test('searchRooms no match', () {
    expect(searchRooms('xyz', campusRoomsSample), isEmpty);
  });
  test('fromJson rejects malformed room', () {
    expect(
      () => CampusRoom.fromJson({'id': 1, 'building': 'B', 'room': 'R'}),
      throwsA(isA<FormatException>()),
    );
  });
  test('fromJson parses valid room', () {
    final r = CampusRoom.fromJson(
      {'id': '9', 'building': 'B', 'room': 'R101', 'floor': '1F'},
    );
    expect(r.id, '9');
    expect(r.floor, '1F');
    expect(r.notes, isNull);
  });
}
