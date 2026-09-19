# Architecture

## Entrypoints

`lib/main.dart` calls `runApp` **before** any `window_manager` setup, so a throwing or hanging window call can never block startup on desktop. It boots into `lib/app.dart`, where `UniPilotApp` owns a `go_router` shell with 4 tabs: schedule, deadlines, GPA, campus.

## Feature / core split

- **Features** (`lib/features/{schedule,deadlines,gpa,campus}/`) — screens, widgets, and feature logic. Each folder is self-contained UI for one tab.
- **Shared** (`lib/core/{db,import,notifications,theme,utils}/`) — cross-feature code. `lib/widgets/` holds reusable widgets such as `NextClassCard` (refreshes on a 60s `Timer`, cancelled in `dispose`).

Tests under `test/` mirror this layout. Widget tests use `test/fakes/fake_database.dart`, never real Drift.

## Data: Drift/SQLite is the source of truth

All persistent state lives in Drift over SQLite (`lib/core/db/`). There is no backend, no network, and no auth — the app works fully offline.

**Validation lives in one shared module.** `lib/core/db/validation.dart` holds every
input guard, throwing typed `ValidationError`s (a field-carrying `ArgumentError`
subclass, so old `isA<ArgumentError>()` expectations still hold). Both the real
`AppDatabase` and the widget-test fake call these validators — add a guard here
once and both stay in sync by construction. UI validation is second-line only.

Domain rules enforced here and in feature logic:

- GPA honors +0.5, capped at the grading scale's max (not a flat 5.0); invalid grades are filtered with a "skipped" count.
- Deadline due dates default to 23:59 end-of-day with an optional time-of-day; save/completion/delete keep T-24h / T-1h reminders in sync.
- Campus search input is trimmed internally.
- Import caps: 512 KB file size, 2000 CSV rows, 1000 ICS events, 52 recurrences.

## State: Riverpod providers

UI reads state through `flutter_riverpod` (2.5.1) providers layered over the database. Widgets watch providers; writes go through DB methods so validation and persistence stay in one place.

## Navigation: go_router shell

`go_router` (14.6.2) provides a stateful shell route with one branch per tab. Deep links land on the right tab; unknown routes hit the error builder instead of a blank screen.

## Import parsers

`lib/core/import/` holds the CSV and ICS parsers with a pre-import preview step. Limits (size, row/event counts, recurrence expansion) are enforced before anything is written, and schedule conflicts are detected against existing courses. Column details: [import-format.md](import-format.md).

## Notifications

Deadlines schedule T-24h and T-1h reminders through `ReminderScheduler`
(`lib/core/notifications/reminder_scheduler.dart`), implemented by
`NotificationService` over `flutter_local_notifications` (19.x) with
`timezone`. Wiring: save schedules, complete cancels, reopen reschedules,
delete cancels — all best-effort (the contract guarantees no throw, so
notification failures can never break a save). Notification ids are
derived deterministically from the assignment id
(`reminderNotificationIds`), so scheduled ids still match their
cancellations after a restart. Android uses inexact alarms (no
exact-alarm permission); Android 13+ permission is requested on save.
Windows shows toasts; on unpackaged builds `cancel` is a platform no-op
(see `docs/windows.md`).

Stack rationale (Flutter for the Android+Windows dual target, Drift for typed offline SQL, Riverpod for CRUD state) is recorded in the local-only `docs/adr/` notes, which are not committed.

Related: [development.md](development.md), [faq.md](faq.md).
