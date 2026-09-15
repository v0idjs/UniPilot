class CampusRoom {
  final String id;
  final String building;
  final String room;
  final String? floor;
  final String? notes;
  const CampusRoom({required this.id, required this.building, required this.room, this.floor, this.notes});

  factory CampusRoom.fromJson(Map<String, dynamic> j) => CampusRoom(
        id: j['id'] as String,
        building: j['building'] as String,
        room: j['room'] as String,
        floor: j['floor'] as String?,
        notes: j['notes'] as String?,
      );
}

/// Stub local data — replace with real campus JSON in assets/campus/rooms.json
const campusRoomsSample = [
  CampusRoom(id: '1', building: 'Main Building', room: 'A101', floor: '1F', notes: 'Near main entrance'),
  CampusRoom(id: '2', building: 'Main Building', room: 'A203', floor: '2F', notes: 'Computer lab'),
  CampusRoom(id: '3', building: 'Science Wing', room: 'S-304', floor: '3F', notes: 'Chemistry lab'),
  CampusRoom(id: '4', building: 'Library', room: 'L-102', floor: '1F', notes: 'Study room 2'),
  CampusRoom(id: '5', building: 'Library', room: 'L-201', floor: '2F', notes: 'Silent zone'),
];

List<CampusRoom> searchRooms(String query, List<CampusRoom> rooms) {
  if (query.trim().isEmpty) return rooms;
  final q = query.toLowerCase();
  return rooms.where((r) => r.building.toLowerCase().contains(q) || r.room.toLowerCase().contains(q) || (r.notes?.toLowerCase().contains(q) ?? false)).toList();
}
