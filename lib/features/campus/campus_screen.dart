import 'package:flutter/material.dart';
import 'campus_data.dart';

class CampusScreen extends StatefulWidget {
  const CampusScreen({super.key});
  @override
  State<CampusScreen> createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final rooms = searchRooms(query, campusRoomsSample);
    return Scaffold(
      appBar: AppBar(title: const Text('Campus')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search building or room', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (c, i) {
              final r = rooms[i];
              return ListTile(
                leading: const Icon(Icons.room),
                title: Text('${r.building} — ${r.room}'),
                subtitle: Text([r.floor, r.notes].whereType<String>().join(' • ')),
              );
            },
          ),
        ),
        // Static map placeholder
        Container(
          height: 140,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('Campus Map — static image placeholder')),
        ),
      ]),
    );
  }
}
