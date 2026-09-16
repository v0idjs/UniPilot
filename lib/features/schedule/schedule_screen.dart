import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/providers.dart';
import '../../widgets/next_class_card.dart';

class ScheduleScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const NextClassCard(slot: null),
          const SizedBox(height: 16),
          courses.when(
            data: (items) {
              if (items.isEmpty) {
                return const _PlaceholderCard(
                  title: 'Daily View',
                  subtitle: 'Today\u2019s classes will appear here',
                );
              }
              return Column(
                children: [
                  for (final c in items)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.book),
                        title: Text('${c.code} — ${c.name}'),
                        subtitle: c.room == null ? null : Text(c.room!),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Card(
              child: ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Loading courses'),
              ),
            ),
            error: (e, _) => Card(
              child: ListTile(
                leading: const Icon(Icons.error),
                title: const Text('Could not load courses'),
                subtitle: Text('$e'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _PlaceholderCard(
            title: 'Weekly Grid',
            subtitle: 'Mon–Sun grid with time slots',
          ),
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

class _AddCourseSheet extends ConsumerStatefulWidget {
  const _AddCourseSheet();
  @override
  ConsumerState<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends ConsumerState<_AddCourseSheet> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

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
          onPressed: _saving
              ? null
              : () async {
                  if (_code.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter course code')));
                    return;
                  }
                  setState(() => _saving = true);
                  try {
                    await ref.read(dbProvider).createCourse(
                          code: _code.text.trim(),
                          name: _name.text.trim().isEmpty ? _code.text.trim() : _name.text.trim(),
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Course ${_code.text.trim()} saved offline')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not save course: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: Text(_saving ? 'Saving' : 'Save'),
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
