import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/utils/time.dart';
import '../../widgets/brand_logo.dart';

class DeadlineListScreen extends ConsumerWidget {
  const DeadlineListScreen({super.key});

  void _showAddDeadline(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const BrandLogo(size: 36),
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
                  trailing: const Icon(Icons.chevron_right),
                  leading: IconButton(
                    icon: Icon(
                      a.completed
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    tooltip: a.completed
                        ? 'Mark incomplete'
                        : 'Mark complete',
                    onPressed: () async {
                      try {
                        await ref.read(dbProvider).setAssignmentCompleted(
                              id: a.id,
                              completed: !a.completed,
                            );
                      } catch (e) {
                        debugPrint('Toggle deadline failed: $e');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not update deadline. Please try again.',
                            ),
                          ),
                        );
                      }
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
                    'Due ${formatDueDate(a.dueAt.toLocal())}'
                    '${a.completed ? ' • Completed' : ''}',
                  ),
                  onTap: () => _showDeadlineDetail(context, a),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            Center(child: Text('Could not load deadlines. Please retry.')),
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
      icon: const BrandLogo(size: 36),
      title: Text(item.title),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Due ${formatDueDate(item.dueAt.toLocal())}'),
        const SizedBox(height: 4),
        Text(item.completed ? 'Status: Completed' : 'Status: Open'),
      ]),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              await ref.read(dbProvider).setAssignmentCompleted(
                    id: item.id,
                    completed: !item.completed,
                  );
            } catch (e) {
              debugPrint('Toggle deadline failed: $e');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not update deadline. Please try again.'),
                ),
              );
              return;
            }
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: Text(item.completed ? 'Mark incomplete' : 'Mark complete'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await ref.read(dbProvider).deleteAssignment(item.id);
            } catch (e) {
              debugPrint('Delete deadline failed: $e');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not delete deadline. Please try again.'),
                ),
              );
              return;
            }
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

  /// Deadlines are date-only in the UI; pin them to end-of-day so a
  /// deadline "today" does not read overdue by the afternoon.
  static DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59);
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
        maxLength: 60,
        decoration: const InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(now.year, now.month, now.day)
                .add(const Duration(days: 1)),
            firstDate: DateTime(now.year, now.month, now.day),
            lastDate: now.add(const Duration(days: 365)),
          );
          if (picked != null) {
            setState(() => _due = _endOfDay(picked));
          }
        },
        child: Text(
          _due == null ? 'Pick due date' : formatDueDate(_due!.toLocal()),
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
                final pickedDue = _due;
                final DateTime due;
                if (pickedDue != null) {
                  due = pickedDue;
                } else {
                  due = _endOfDay(
                    DateTime.now().add(const Duration(days: 1)),
                  );
                }
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
                  debugPrint('Save deadline failed: $e');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not save deadline. Please try again.',
                      ),
                    ),
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
