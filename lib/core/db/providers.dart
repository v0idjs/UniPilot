import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'database_api.dart';

final dbProvider = Provider<UniPilotDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final coursesProvider = StreamProvider<List<Course>>((ref) {
  return ref.watch(dbProvider).watchCourses();
});

final assignmentsProvider = StreamProvider<List<Assignment>>((ref) {
  return ref.watch(dbProvider).watchAssignments();
});

final semestersProvider = StreamProvider<List<Semester>>((ref) {
  return ref.watch(dbProvider).watchSemesters();
});
