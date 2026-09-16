# TDD Evidence — Issue #1: transparent window + invisible offline saves

## Source plan

No `*.plan.md` was provided. User journeys were derived from
issue #1 ("Windows shows transparent window and Android saves do not
appear in lists") during this TDD run.

## User journeys

1. As a student on Windows, I want the app to open in an opaque window
   with content visible, so that I can use it on first launch.
2. As a student on Android, I want a course I add to appear in Schedule,
   so that my data is actually kept.
3. As a student on Android, I want a deadline I add to appear in
   Deadlines, so that I can track it.
4. As a student on Android, I want a semester I add to appear in GPA,
   so that I can calculate grades.

## Task report

| Task | Summary | Validation | Outcome |
|------|---------|------------|---------|
| Reproducers (RED) | Added 6 failing tests covering opaque window config, DB persistence of courses/deadlines/semesters, widget save flows, and icon sourcing | `git show da2b537 --stat`; static check: `desktop_window.dart` absent, `createCourse`/`watchCourses` absent from `app_database.dart`, `logo.svg` absent from `flutter_launcher_icons.yaml`, `backgroundColor: Colors.transparent` present in `main.dart` | RED by construction: every new test referenced symbols that did not exist yet, so the targets could not compile; the transparent background and SnackBar-only saves were still in the tree |
| Minimal fix (GREEN) | Opaque desktop window options; Drift create/watch methods with Riverpod providers; screens persist on save and render from stored state; icon config references the brand vector | CI `35095670814`, job `analyze-test`, `flutter test --coverage` exit 0 in 1m55s | GREEN: full suite passed; previously failing workflow is now `completed success` |
| Dependency repair | Dropped the incompatible database adapter after CI proved `drift_flutter 0.2.7` vs `drift 2.23.1` unresolvable (`isolateDebugLog` compile error in CI `35090514150`) | Same CI run log showing the `native.dart` error, then success after removal | Real async path unblocked with the direct native driver |
| Test-hang repair | Replaced drift-backed widget tests with a pure-Dart fake after CI proved drift query streams deadlock the widget-test fake clock (10-minute timeout each, cancelled runs `35091079509`/`35092878537`; `StreamQueryStore.markAsClosed` pending-timer log) | CI `35095670814` success in 1m59s | Widget tests hermetic and fast; no native sqlite in widget tests |

Note on execution environment: no Flutter SDK is installed on this
machine, so RED was verified by static absence checks plus CI logs, and
GREEN was verified by the CI workflow result rather than a local run.
Per-test log lines could not be re-fetched (log download failed with a
TLS timeout), so GREEN is attested by the workflow exit code: this
workflow exits non-zero on any test failure, as demonstrated by the
earlier `completed failure` run.

## Test specification

| # | Guarantee | Test | Type | Result |
|---|-----------|------|------|--------|
| 1 | Desktop window is opaque with 1280x800 centered defaults | `test/core/desktop_window_test.dart` | unit | PASS (CI `35095670814`) |
| 2 | Saved course is persisted and streamed to schedule | `test/core/db_persistence_test.dart` | integration | PASS (CI `35095670814`) |
| 3 | Saved deadline is persisted and streamed to deadlines | `test/core/db_persistence_test.dart` | integration | PASS (CI `35095670814`) |
| 4 | Saved semester is persisted and streamed to GPA | `test/core/db_persistence_test.dart` | integration | PASS (CI `35095670814`) |
| 5 | Added course appears in the schedule list | `test/features/schedule/schedule_screen_test.dart` | widget | PASS (CI `35095670814`) |
| 6 | Added deadline appears in the deadlines list | `test/features/deadlines/deadline_list_screen_test.dart` | widget | PASS (CI `35095670814`) |
| 7 | Added semester appears in the GPA screen | `test/features/gpa/gpa_screen_test.dart` | widget | PASS (CI `35095670814`) |
| 8 | Brand logo is the icon source for Android and Windows | `test/icon/logo_icon_test.dart` | unit | PASS (CI `35095670814`) |
| 9 | Full app builds with navigation | `test/widget_test.dart` | widget | PASS (CI `35095670814`) |

## Coverage and known gaps

- `flutter test --coverage` ran green in CI; the exact percentage was
  not captured (log artifact fetch failed), so no number is claimed.
- Pre-existing unit tests (schedule service, GPA calculator, parsers,
  campus, time) all still pass.
- No on-device manual verification yet: Windows opacity should be
  eyeballed once, and the Android add flows tapped through on an
  emulator or device.
- No end-to-end suite exists; widget tests cover the reported flows.

## Merge evidence

Checkpoint commits on `main` for this task, in order:

- `da2b537` test: add reproducers for transparent window and invisible
  offline saves (issue #1, RED)
- `ed0e2fb` fix: opaque desktop window and persist offline saves to
  lists (issue #1, GREEN)
- `e74d4c0` fix: drop drift_flutter for native database to unblock tests
- `0c8f12b` test: use bounded pumps to avoid settling on infinite spinners
- `4a31e2b` test: use pure-Dart fake database in widget tests to avoid
  drift timer hangs

Each message describes its stage and evidence; all are reachable from
`HEAD` on `main`.
