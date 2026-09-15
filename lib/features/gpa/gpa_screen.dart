import 'package:flutter/material.dart';

class GpaScreen extends StatelessWidget {
  const GpaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: const Center(child: Text('Add semesters and grades to calculate GPA')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Semester'),
      ),
    );
  }
}
