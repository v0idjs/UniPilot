import 'package:flutter/material.dart';
import '../../widgets/next_class_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  void _showAddCourse(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _AddCourseSheet(),
      ),
    );
  }

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
        onPressed: () => _showAddCourse(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }
}

class _AddCourseSheet extends StatefulWidget {
  const _AddCourseSheet();
  @override
  State<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<_AddCourseSheet> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Add Course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(controller: _code, decoration: const InputDecoration(labelText: 'Course code', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Course name', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            if (_code.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter course code')));
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course ${_code.text} added — offline saved')));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
        const SizedBox(height: 12),
      ]),
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
