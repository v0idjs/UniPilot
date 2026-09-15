import 'package:drift/drift.dart';

class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('232946'))();
  TextColumn get room => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ScheduleEntries extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().customConstraint('REFERENCES courses(id) ON DELETE CASCADE')();
  IntColumn get dayOfWeek => integer()();
  IntColumn get startMinutes => integer()();
  IntColumn get endMinutes => integer()();
  TextColumn get room => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Assignments extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get courseId => text().nullable().customConstraint('REFERENCES courses(id) ON DELETE SET NULL')();
  // type: assignment | exam
  TextColumn get type => text().withDefault(const Constant('assignment'))();
  DateTimeColumn get dueAt => dateTime()();
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 0 low,1 medium,2 high
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Semesters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // e.g. Fall 2025
  TextColumn get gradingScaleId => text().withDefault(const Constant('gpa_4_0'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CourseGrades extends Table {
  TextColumn get id => text()();
  TextColumn get semesterId => text().customConstraint('REFERENCES semesters(id) ON DELETE CASCADE')();
  TextColumn get courseName => text()();
  TextColumn get grade => text()(); // A, B+, 85, etc.
  RealColumn get credits => real().withDefault(const Constant(3.0))();
  BoolColumn get isPassFail => boolean().withDefault(const Constant(false))();
  BoolColumn get isHonors => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CampusRooms extends Table {
  TextColumn get id => text()();
  TextColumn get building => text()();
  TextColumn get room => text()();
  TextColumn get floor => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
