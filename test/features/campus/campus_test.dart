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
}
