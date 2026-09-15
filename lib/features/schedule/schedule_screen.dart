import 'package:flutter/material.dart';
import '../../widgets/next_class_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NextClassCard(slot: null),
          SizedBox(height: 16),
          _PlaceholderCard(title: 'Daily View', subtitle: 'Today\u2019s classes will appear here'),
          SizedBox(height: 12),
          _PlaceholderCard(title: 'Weekly Grid', subtitle: 'Mon–Sun grid with time slots'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  final String title; final String subtitle;
  const _PlaceholderCard({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(title), subtitle: Text(subtitle), leading: const Icon(Icons.calendar_view_week)));
  }
}
