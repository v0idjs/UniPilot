import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/utils/time.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/next_class_card.dart';
import 'schedule_service.dart';

const _dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  void _showCourseForm(BuildContext context, {Course? course}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CourseFormSheet(course: course),
      ),
    );
  }

  void _showCourseDetail(BuildContext context, Course course) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CourseDetailSheet(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final entriesAsync = ref.watch(entriesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: BrandLogo(size: 28),
        ),
        title: const Text('Schedule'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          coursesAsync.when(
            data: (courses) => entriesAsync.when(
              data: (entries) => NextClassCard(
                slot: _nextSlot(courses, entries),
              ),
              loading: () => const NextClassCard(slot: null),
              error: (_, __) => const NextClassCard(slot: null),
            ),
            loading: () => const NextClassCard(slot: null),
            error: (_, __) => const NextClassCard(slot: null),
          ),
          const SizedBox(height: 16),
          coursesAsync.when(
            data: (courses) {
              if (courses.isEmpty) {
                return EmptyState(
                  icon: Icons.event_note,
                  title: 'No courses yet',
                  subtitle:
                      'Add your first course to build your schedule',
                  actionLabel: 'Add course',
                  onAction: () => _showCourseForm(context),
                );
              }
              return Column(
                children: [
                  for (final c in courses)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.book),
                        title: Text('${c.code} — ${c.name}'),
                        subtitle:
                            c.room == null ? null : Text(c.room!),
                        trailing:
                            const Icon(Icons.chevron_right),
                        onTap: () => _showCourseDetail(context, c),
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
            error: (e, _) => AppErrorView(
              message: 'Could not load courses: $e',
              onRetry: () => ref.invalidate(coursesProvider),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Weekly',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return const EmptyState(
                  icon: Icons.calendar_view_week,
                  title: 'No time slots yet',
                  subtitle: 'Open a course to add weekly time slots',
                );
              }
              return coursesAsync.when(
                data: (courses) {
                  final codeById = {
                    for (final c in courses) c.id: c.code,
                  };
                  return Column(
                    children: [
                      for (final e in entries)
                        Card(
                          child: ListTile(
                            leading:
                                const Icon(Icons.calendar_view_week),
                            title: Text(
                              '${_dayNames[e.dayOfWeek - 1]} '
                              '${formatMinutes(e.startMinutes)}–'
                              '${formatMinutes(e.endMinutes)}',
                            ),
                            subtitle: Text(
                              codeById[e.courseId] ?? 'Course',
                            ),
                            trailing: _EntryDeleteButton(entry: e),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, _) => AppErrorView(
              message: 'Could not load time slots: $e',
              onRetry: () => ref.invalidate(entriesProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }
}

ScheduleSlot? _nextSlot(List<Course> courses, List<ScheduleEntry> entries) {
  final byId = {for (final c in courses) c.id: c};
  final slots = <ScheduleSlot>[];
  for (final e in entries) {
    final c = byId[e.courseId];
    if (c == null) continue;
    slots.add(
      ScheduleSlot(
        id: e.id,
        courseId: e.courseId,
        courseCode: c.code,
        courseName: c.name,
        dayOfWeek: e.dayOfWeek,
        startMinutes: e.startMinutes,
        endMinutes: e.endMinutes,
        room: e.room,
      ),
    );
  }
  return nextClass(slots, DateTime.now());
}

class _EntryDeleteButton extends ConsumerWidget {
  final ScheduleEntry entry;
  const _EntryDeleteButton({required this.entry});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Delete time slot',
      onPressed: () async {
        await ref.read(dbProvider).deleteEntry(entry.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot deleted')),
        );
      },
    );
  }
}

class _CourseDetailSheet extends ConsumerWidget {
  final Course course;
  const _CourseDetailSheet({required this.course});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          course.code,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(course.name),
        if (course.room != null) ...[
          const SizedBox(height: 4),
          Text('Room ${course.room!}'),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    ),
                    child: _CourseFormSheet(course: course),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    ),
                    child: _TimeSlotSheet(course: course),
                  ),
                );
              },
              child: const Text('Add time slot'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () async {
                await ref.read(dbProvider).deleteCourse(course.id);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _CourseFormSheet extends ConsumerStatefulWidget {
  final Course? course;
  const _CourseFormSheet({this.course});
  @override
  ConsumerState<_CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends ConsumerState<_CourseFormSheet> {
  late final TextEditingController _code;
  late final TextEditingController _name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.course?.code ?? '');
    _name = TextEditingController(text: widget.course?.name ?? '');
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.course != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          editing ? 'Edit Course' : 'Add Course',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _code,
          decoration: const InputDecoration(
            labelText: 'Course code',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Course name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (_code.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter course code')),
                    );
                    return;
                  }
                  setState(() => _saving = true);
                  try {
                    final db = ref.read(dbProvider);
                    if (editing) {
                      await db.updateCourse(
                        id: widget.course!.id,
                        code: _code.text.trim(),
                        name: _name.text.trim().isEmpty
                            ? _code.text.trim()
                            : _name.text.trim(),
                      );
                    } else {
                      await db.createCourse(
                        code: _code.text.trim(),
                        name: _name.text.trim().isEmpty
                            ? _code.text.trim()
                            : _name.text.trim(),
                      );
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          editing
                              ? 'Course updated'
                              : 'Course ${_code.text.trim()} saved offline',
                        ),
                      ),
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
          child: Text(_saving ? 'Saving' : (editing ? 'Save changes' : 'Save')),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _TimeSlotSheet extends ConsumerStatefulWidget {
  final Course course;
  const _TimeSlotSheet({required this.course});
  @override
  ConsumerState<_TimeSlotSheet> createState() => _TimeSlotSheetState();
}

class _TimeSlotSheetState extends ConsumerState<_TimeSlotSheet> {
  int _day = 1;
  int _start = 540;
  int _end = 600;
  bool _saving = false;

  Future<void> _pickTime(bool isStart) async {
    final initial = TimeOfDay(
      hour: (isStart ? _start : _end) ~/ 60,
      minute: (isStart ? _start : _end) % 60,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      final minutes = picked.hour * 60 + picked.minute;
      if (isStart) {
        _start = minutes;
        if (_end <= _start) _end = _start + 60;
      } else {
        _end = minutes;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          'Time slot for ${widget.course.code}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _day,
          decoration: const InputDecoration(
            labelText: 'Day',
            border: OutlineInputBorder(),
          ),
          items: [
            for (var i = 0; i < 7; i++)
              DropdownMenuItem(value: i + 1, child: Text(_dayNames[i])),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _day = v);
          },
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(true),
              child: Text('Start ${formatMinutes(_start)}'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(false),
              child: Text('End ${formatMinutes(_end)}'),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (_end <= _start) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('End time must be after start time'),
                      ),
                    );
                    return;
                  }
                  setState(() => _saving = true);
                  try {
                    final db = ref.read(dbProvider);
                    final courses =
                        ref.read(coursesProvider).valueOrNull ?? [];
                    final entries =
                        ref.read(entriesProvider).valueOrNull ?? [];
                    final byId = {for (final c in courses) c.id: c};
                    final slots = <ScheduleSlot>[];
                    for (final e in entries) {
                      final c = byId[e.courseId];
                      if (c == null) continue;
                      slots.add(
                        ScheduleSlot(
                          id: e.id,
                          courseId: e.courseId,
                          courseCode: c.code,
                          courseName: c.name,
                          dayOfWeek: e.dayOfWeek,
                          startMinutes: e.startMinutes,
                          endMinutes: e.endMinutes,
                        ),
                      );
                    }
                    final candidate = ScheduleSlot(
                      id: 'new',
                      courseId: widget.course.id,
                      courseCode: widget.course.code,
                      courseName: widget.course.name,
                      dayOfWeek: _day,
                      startMinutes: _start,
                      endMinutes: _end,
                    );
                    final clash = detectConflicts([...slots, candidate]).any(
                      (c) => c.a.id == 'new' || c.b.id == 'new',
                    );
                    if (clash) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Conflicts with an existing time slot',
                          ),
                        ),
                      );
                      return;
                    }
                    await db.createEntry(
                      courseId: widget.course.id,
                      dayOfWeek: _day,
                      startMinutes: _start,
                      endMinutes: _end,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Time slot saved')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not save slot: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: Text(_saving ? 'Saving' : 'Save slot'),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}
