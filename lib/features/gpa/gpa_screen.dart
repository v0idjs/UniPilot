import 'package:flutter/material.dart';

class GpaScreen extends StatelessWidget {
  const GpaScreen({super.key});

  void _showAddSemester(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Semester', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Create a semester to add course grades. GPA will be calculated automatically.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Semester added — add courses to calculate GPA')));
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: const Center(child: Text('Add semesters and grades to calculate GPA')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSemester(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Semester'),
      ),
    );
  }
}
