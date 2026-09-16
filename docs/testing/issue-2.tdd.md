# TDD Evidence — Issue #2: dead rows + white desktop screen

## Source plan

No `*.plan.md` was provided. User journeys were derived from
issue #2 ("List rows do nothing when tapped and Windows shows a white
screen") during this TDD run, using the supplied screenshots as
acceptance input.

## User journeys

1. As a student, I want tapping a course to open details with edit and
   delete, so that I can manage my schedule.
2. As a student, I want to add weekly time slots per course with
   conflict detection, so that the weekly overview reflects reality.
3. As a student, I want to mark deadlines complete and delete them, so
   that the list tracks real progress.
4. As a student, I want tapping a semester to show grades with a
   computed GPA, so that I can plan my results.
5. As a student, I want tapping a campus room to show its details, so
   that I can find my way.
6. As a student on Windows, I want content painted even if a window API
   call fails, so that I never face a blank screen.

## Task report

| Task | Summary | Validation | Outcome |
|------|---------|------------|---------|
| Reproducers (RED) | Extended DB tests with edit/delete/slots/toggle/grades cases and added 5 tap-flow widget tests | CI `35126247558`: `completed failure`, 44 passed / 7 failed — widget finders found 0 `Delete`/`Edit`/`Add time slot`/`Add grade`/checkbox widgets, and `db_persistence_test.dart` failed to compile on the missing methods (`updateCourse`, `createEntry`, `setAssignmentCompleted`, `createGrade`, …) | Genuine runtime + compile-time RED for exactly the reported gaps |
| Minimal fix (GREEN) | Detail/edit/delete sheets, slot form with conflict check, deadline toggle + detail, semester grades with computed GPA, room details, resilient startup | CI `35128983234`: 56 passed / 1 failed — only the campus sheet overflowed (33px RenderFlex) | All reported behaviors GREEN; one layout defect left |
| Overflow fix | Campus detail sheet made scrollable | CI `35130119275`: `completed success`, full suite green | 57/57 GREEN |

Desktop startup reasoning: the white (previously transparent) window
with a visible frame but no painted content matches `runApp` never
being reached — the old `main` awaited window calls before `runApp`,
so a throwing call skipped the app entirely. The fix paints first and
treats window setup as best effort inside try/catch. This path cannot
execute in CI; on-device eyeballing of the Windows build is recorded
as a known gap below.

## Test specification

| # | Guarantee | Test | Type | Result |
|---|-----------|------|------|--------|
| 1 | Course can be edited and deleted | `test/core/db_persistence_test.dart` | integration | PASS (CI `35130119275`) |
| 2 | Time slots stored per course, streamed weekly | `test/core/db_persistence_test.dart` | integration | PASS (CI `35130119275`) |
| 3 | Deadline can be marked complete and deleted | `test/core/db_persistence_test.dart` | integration | PASS (CI `35130119275`) |
| 4 | Grades stored per semester, semester deletes cascade | `test/core/db_persistence_test.dart` | integration | PASS (CI `35130119275`) |
| 5 | Tapping a course opens details with delete | `test/features/schedule/course_detail_test.dart` | widget | PASS (CI `35130119275`) |
| 6 | Tapping a course allows editing code and name | `test/features/schedule/course_detail_test.dart` | widget | PASS (CI `35130119275`) |
| 7 | Added time slot renders in the weekly section | `test/features/schedule/weekly_slots_test.dart` | widget | PASS (CI `35130119275`) |
| 8 | Checking a deadline marks it complete | `test/features/deadlines/deadline_detail_test.dart` | widget | PASS (CI `35130119275`) |
| 9 | Tapping a deadline opens details with delete | `test/features/deadlines/deadline_detail_test.dart` | widget | PASS (CI `35130119275`) |
| 10 | Tapping a semester shows grades and computed GPA | `test/features/gpa/semester_detail_test.dart` | widget | PASS (CI `35130119275`) |
| 11 | Tapping a campus room opens its details | `test/features/campus/campus_detail_test.dart` | widget | PASS (CI `35130119275`) |

All issue #1 tests still pass unmodified (regression).

## Coverage and known gaps

- `flutter test --coverage` ran green in CI; exact percentage not
  captured, so no number is claimed.
- Desktop startup path needs a manual Windows launch to eyeball first
  paint; CI cannot execute window APIs.
- No end-to-end suite; widget tests cover the reported flows.

## Merge evidence

Checkpoint commits on `main` for this task, in order:

- `318ed4e` test: add reproducers for dead rows and missing detail
  actions (issue #2, RED)
- `9d7676c` fix: tappable rows with detail/edit/delete plus resilient
  desktop startup (issue #2, GREEN)
- `d16cab4` fix: make campus detail sheet scrollable to prevent
  overflow

Each message describes its stage and evidence; all are reachable from
`HEAD` on `main`.
