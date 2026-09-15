# UniPilot — Your Personal University Co-Pilot

Offline-first Flutter app: schedule, deadlines, GPA, campus room finder. Single codebase → Android APK + Windows exe via GitHub Actions.

## Brand
- Primary indigo `#1E1B4B`, accent amber `#F4A300`, typography Inter + Sora.

## Stack
Flutter 3.24.x · Drift/SQLite · Riverpod · go_router · flutter_local_notifications · csv/ics parsers

## Features (v1.0)
- **Smart Schedule**: daily/weekly view, next-class card, manual CRUD, CSV/ICS import with preview, conflict detection
- **Deadline Tracker**: assignments/exams, countdown, local notifications (T-24h/T-1h), offline badge
- **GPA Calculator**: per-semester + cumulative, 4.0/4.3/5.0/percentage/custom, what-if
- **Campus**: searchable room list + static map (stub — local JSON)
- **Offline**: Drift is source of truth, no network required

## Quick Start
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
flutter run -d windows  # or android
```

## Project Layout
```
lib/core/{theme,db,notifications,import,utils}
lib/features/{schedule,deadlines,gpa,campus}
lib/widgets/
assets/samples/  # CSV/ICS fixtures
test/            # unit + widget tests
```

## CI/CD
Tag `v*` triggers `build-apk` (ubuntu) + `build-windows` (windows-latest). Both pinned to Flutter 3.24.0. See `docs/release.md`.

## Docs
- `docs/adr/001-stack.md`
- `docs/import-format.md`
- `docs/release.md`
