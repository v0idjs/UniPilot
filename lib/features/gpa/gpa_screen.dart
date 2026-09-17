import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../widgets/brand_logo.dart';
import 'calculator.dart';
import 'grading_scales.dart';

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

  void _showSemesterDetail(BuildContext context, Semester semester) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _SemesterDetailSheet(semester: semester),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(semestersProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: BrandLogo(size: 28),
        ),
        title: const Text('GPA Calculator'),
      ),
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
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSemesterDetail(context, s),
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

class _SemesterDetailSheet extends ConsumerWidget {
  final Semester semester;
  const _SemesterDetailSheet({required this.semester});

  void _showAddGrade(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _GradeFormSheet(semester: semester),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesAsync = ref.watch(gradesProvider(semester.id));
    final scale = scaleById(semester.gradingScaleId);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          semester.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        gradesAsync.when(
          data: (grades) {
            final gpa = calculateGpa(
              [
                for (final g in grades)
                  CourseInput(
                    grade: g.grade,
                    credits: g.credits,
                    isPassFail: g.isPassFail,
                    isHonors: g.isHonors,
                  ),
              ],
              scale,
            );
            return Text(
              grades.isEmpty ? 'No grades yet' : 'GPA $gpa',
              style: const TextStyle(fontSize: 16),
            );
          },
          loading: () => const Text('Loading grades'),
          error: (e, _) => Text('Could not load grades: $e'),
        ),
        const SizedBox(height: 8),
        gradesAsync.when(
          data: (grades) => Column(
            children: [
              for (final g in grades)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(g.courseName),
                  subtitle: Text(
                    'Grade ${g.grade} • ${g.credits} credits',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete grade',
                    onPressed: () {
                      ref.read(dbProvider).deleteGrade(g.id);
                    },
                  ),
                ),
            ],
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showAddGrade(context),
              child: const Text('Add grade'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () async {
                await ref.read(dbProvider).deleteSemester(semester.id);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semester deleted')),
                );
              },
              child: const Text('Delete semester'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _GradeFormSheet extends ConsumerStatefulWidget {
  final Semester semester;
  const _GradeFormSheet({required this.semester});
  @override
  ConsumerState<_GradeFormSheet> createState() => _GradeFormSheetState();
}

class _GradeFormSheetState extends ConsumerState<_GradeFormSheet> {
  final _course = TextEditingController();
  final _grade = TextEditingController(text: 'A');
  final _credits = TextEditingController(text: '3');
  bool _saving = false;
  @override
  void dispose() {
    _course.dispose();
    _grade.dispose();
    _credits.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text(
          'Add grade',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _course,
          decoration: const InputDecoration(
            labelText: 'Course',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _grade,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _credits,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (_course.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter course name')),
                    );
                    return;
                  }
                  final scale =
                      scaleById(widget.semester.gradingScaleId);
                  if (!scale.isValidGrade(_grade.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid grade')),
                    );
                    return;
                  }
                  final credits =
                      double.tryParse(_credits.text.trim()) ?? -1;
                  if (credits <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter valid credits')),
                    );
                    return;
                  }
                  setState(() => _saving = true);
                  try {
                    await ref.read(dbProvider).createGrade(
                          semesterId: widget.semester.id,
                          courseName: _course.text.trim(),
                          grade: _grade.text.trim(),
                          credits: credits,
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Grade saved')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not save grade: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: Text(_saving ? 'Saving' : 'Save grade'),
        ),
        const SizedBox(height: 12),
      ]),
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
