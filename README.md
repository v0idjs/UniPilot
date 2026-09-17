# UniPilot — Your Personal University Co-Pilot

[![CI](https://github.com/v0idjs/UniPilot/actions/workflows/ci.yml/badge.svg)](https://github.com/v0idjs/UniPilot/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/v0idjs/UniPilot?label=release)](https://github.com/v0idjs/UniPilot/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<img src="assets/logo.svg" width="140" alt="UniPilot Logo">

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
Tag `v*` triggers `Release UniPilot` workflow (universal APK + Windows zip + auto release notes). See `docs/release.md`.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). PRs welcome — please add tests.

## License
MIT — see [LICENSE](LICENSE).

## Docs
- `docs/adr/001-stack.md`
- `docs/import-format.md`
- `docs/release.md`
- `docs/windows.md`
- `CHANGELOG.md`
