import 'package:flutter/material.dart';

class DeadlineListScreen extends StatelessWidget {
  const DeadlineListScreen({super.key});

  void _showAddDeadline(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Deadline'),
        content: const _AddDeadlineForm(),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deadlines')),
      body: const Center(child: Text('No deadlines yet — add one')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeadline(context),
        icon: const Icon(Icons.add_task),
        label: const Text('Add Deadline'),
      ),
    );
  }
}

class _AddDeadlineForm extends StatefulWidget {
  const _AddDeadlineForm();
  @override
  State<_AddDeadlineForm> createState() => _AddDeadlineFormState();
}

class _AddDeadlineFormState extends State<_AddDeadlineForm> {
  final _title = TextEditingController();
  DateTime? _due;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () async {
          final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (picked != null) setState(() => _due = picked);
        },
        child: Text(_due == null ? 'Pick due date' : _due.toString().split(' ')[0]),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () {
          if (_title.text.trim().isEmpty || _due == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter title and due date')));
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deadline "${_title.text}" saved')));
          Navigator.pop(context);
        },
        child: const Text('Save'),
      ),
    ]);
  }
}
