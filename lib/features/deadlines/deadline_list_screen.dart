import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../widgets/brand_logo.dart';

class DeadlineListScreen extends ConsumerWidget {
  const DeadlineListScreen({super.key});

  void _showAddDeadline(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Deadline'),
        content: const _AddDeadlineForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeadlineDetail(BuildContext context, Assignment item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DeadlineDetailDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(assignmentsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: BrandLogo(size: 28),
        ),
        title: const Text('Deadlines'),
      ),
      body: items.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No deadlines yet — add one'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final a = list[i];
              return Card(
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(
                      a.completed
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    tooltip: a.completed
                        ? 'Mark incomplete'
                        : 'Mark complete',
                    onPressed: () {
                      ref.read(dbProvider).setAssignmentCompleted(
                            id: a.id,
                            completed: !a.completed,
                          );
                    },
                  ),
                  title: Text(
                    a.title,
                    style: a.completed
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  subtitle: Text(
                    'Due ${a.dueAt.toLocal().toString().split(' ')[0]}'
                    '${a.completed ? ' • Completed' : ''}',
                  ),
                  onTap: () => _showDeadlineDetail(context, a),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load deadlines: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeadline(context),
        icon: const Icon(Icons.add_task),
        label: const Text('Add Deadline'),
      ),
    );
  }
}

class _DeadlineDetailDialog extends ConsumerWidget {
  final Assignment item;
  const _DeadlineDetailDialog({required this.item});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(item.title),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Due ${item.dueAt.toLocal().toString().split(' ')[0]}'),
        const SizedBox(height: 4),
        Text(item.completed ? 'Status: Completed' : 'Status: Open'),
      ]),
      actions: [
        TextButton(
          onPressed: () async {
            await ref.read(dbProvider).setAssignmentCompleted(
                  id: item.id,
                  completed: !item.completed,
                );
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: Text(item.completed ? 'Mark incomplete' : 'Mark complete'),
        ),
        TextButton(
          onPressed: () async {
            await ref.read(dbProvider).deleteAssignment(item.id);
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Deadline deleted')),
            );
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AddDeadlineForm extends ConsumerStatefulWidget {
  const _AddDeadlineForm();
  @override
  ConsumerState<_AddDeadlineForm> createState() => _AddDeadlineFormState();
}

class _AddDeadlineFormState extends ConsumerState<_AddDeadlineForm> {
  final _title = TextEditingController();
  DateTime? _due;
  bool _saving = false;
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(
        controller: _title,
        decoration: const InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) setState(() => _due = picked);
        },
        child: Text(
          _due == null ? 'Pick due date' : _due.toString().split(' ')[0],
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _saving
            ? null
            : () async {
                if (_title.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter title')),
                  );
                  return;
                }
                final due =
                    _due ?? DateTime.now().add(const Duration(days: 1));
                setState(() => _saving = true);
                try {
                  await ref.read(dbProvider).createAssignment(
                        title: _title.text.trim(),
                        dueAt: due,
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Deadline "${_title.text.trim()}" saved offline',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not save deadline: $e')),
                  );
                } finally {
                  if (mounted) setState(() => _saving = false);
                }
              },
        child: Text(_saving ? 'Saving' : 'Save'),
      ),
    ]);
  }
}
