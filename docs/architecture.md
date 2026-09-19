# Architecture

## Entrypoints

`lib/main.dart` calls `runApp` **before** any `window_manager` setup, so a throwing or hanging window call can never block startup on desktop. It boots into `lib/app.dart`, where `UniPilotApp` owns a `go_router` shell with 4 tabs: schedule, deadlines, GPA, campus.

## Feature / core split

- **Features** (`lib/features/{schedule,deadlines,gpa,campus}/`) — screens, widgets, and feature logic. Each folder is self-contained UI for one tab.
- **Shared** (`lib/core/{db,import,notifications,theme,utils}/`) — cross-feature code. `lib/widgets/` holds reusable widgets such as `NextClassCard` (refreshes on a 60s `Timer`, cancelled in `dispose`).

Tests under `test/` mirror this layout. Widget tests use `test/fakes/fake_database.dart`, never real Drift.

## Data: Drift/SQLite is the source of truth

All persistent state lives in Drift over SQLite (`lib/core/db/`). There is no backend, no network, and no auth — the app works fully offline.

**Validation lives at the DB layer.** `AppDatabase.create*` methods throw `ArgumentError` on empty, oversize, or out-of-range input. UI validation is second-line only. The fake in `test/fakes/fake_database.dart` mirrors these guards — when you add a guard in `AppDatabase`, add the same `ArgumentError` in the fake or widget tests will diverge from prod.

Domain rules enforced here and in feature logic:

- GPA honors +0.5, capped at the grading scale's max (not a flat 5.0); invalid grades are filtered with a "skipped" count.
- Deadline due dates pin to 23:59 end-of-day.
- Campus search input is trimmed internally.
- Import caps: 512 KB file size, 2000 CSV rows, 1000 ICS events, 52 recurrences.

## State: Riverpod providers

UI reads state through `flutter_riverpod` (2.5.1) providers layered over the database. Widgets watch providers; writes go through DB methods so validation and persistence stay in one place.

## Navigation: go_router shell

`go_router` (14.6.2) provides a stateful shell route with one branch per tab. Deep links land on the right tab; unknown routes hit the error builder instead of a blank screen.

## Import parsers

`lib/core/import/` holds the CSV and ICS parsers with a pre-import preview step. Limits (size, row/event counts, recurrence expansion) are enforced before anything is written, and schedule conflicts are detected against existing courses. Column details: [import-format.md](import-format.md).

## Notifications: stub status

`NotificationService` (`lib/core/notifications/`) exists and `flutter_local_notifications` (17.1.2) is wired as a dependency, but **the service has no callers yet — reminders are not scheduled**. The T-24h / T-1h deadline reminder design is recorded in [adr/002-notifications.md](adr/002-notifications.md); wiring it up is future work.

Related: [adr/001-stack.md](adr/001-stack.md) (why Flutter + Drift + Riverpod), [development.md](development.md), [faq.md](faq.md).
