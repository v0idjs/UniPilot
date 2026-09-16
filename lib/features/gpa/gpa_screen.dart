import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/providers.dart';

class GpaScreen extends ConsumerWidget {
  const GpaScreen({super.key});

  void _showAddSemester(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => const Padding(
        padding: EdgeInsets.all(16),
        child: _AddSemesterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(semestersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: semesters.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('Add semesters and grades to calculate GPA'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final s = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(s.name),
                  subtitle: const Text('Add courses to calculate GPA'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load semesters: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSemester(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Semester'),
      ),
    );
  }
}

class _AddSemesterSheet extends ConsumerStatefulWidget {
  const _AddSemesterSheet();
  @override
  ConsumerState<_AddSemesterSheet> createState() => _AddSemesterSheetState();
}

class _AddSemesterSheetState extends ConsumerState<_AddSemesterSheet> {
  final _name = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Add Semester', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextField(
        controller: _name,
        decoration: const InputDecoration(
          labelText: 'Semester name',
          hintText: 'Fall 2026',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _saving
            ? null
            : () async {
                if (_name.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter semester name')),
                  );
                  return;
                }
                setState(() => _saving = true);
                try {
                  await ref.read(dbProvider).createSemester(name: _name.text.trim());
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semester saved offline')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not save semester: $e')),
                  );
                } finally {
                  if (mounted) setState(() => _saving = false);
                }
              },
        child: Text(_saving ? 'Saving' : 'Create'),
      ),
      const SizedBox(height: 12),
    ]);
  }
}
