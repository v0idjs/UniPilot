import 'package:flutter/material.dart';

class DeadlineListScreen extends StatelessWidget {
  const DeadlineListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deadlines')),
      body: const Center(child: Text('No deadlines yet — add one')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_task),
        label: const Text('Add Deadline'),
      ),
    );
  }
}
