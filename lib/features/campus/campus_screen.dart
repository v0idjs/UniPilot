import 'package:flutter/material.dart';
import '../../widgets/brand_logo.dart';
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
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: BrandLogo(size: 28),
        ),
        title: const Text('Campus'),
      ),
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
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          const Text(
                            'Room details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.business),
                            title: const Text('Building'),
                            subtitle: Text(r.building),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.door_front_door),
                            title: const Text('Room'),
                            subtitle: Text(r.room),
                          ),
                          if (r.floor != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.layers),
                              title: const Text('Floor'),
                              subtitle: Text(r.floor!),
                            ),
                          if (r.notes != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.notes),
                              title: const Text('Notes'),
                              subtitle: Text(r.notes!),
                            ),
                          const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
