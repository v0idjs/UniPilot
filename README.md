# UniPilot — Your Personal University Co-Pilot

[![CI](https://github.com/v0idjs/UniPilot/actions/workflows/ci.yml/badge.svg)](https://github.com/v0idjs/UniPilot/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/v0idjs/UniPilot?label=release)](https://github.com/v0idjs/UniPilot/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/v0idjs/UniPilot)](https://github.com/v0idjs/UniPilot/stargazers)

<img src="assets/logo.svg" width="140" alt="UniPilot Logo">

Offline-first Flutter app for students: class schedule, deadline tracking, GPA calculation, and campus room finder. No backend, no network, no accounts — your data stays in local SQLite on your device.

<!-- screenshot: no screenshots checked in yet. To add one, run the app and capture with `flutter screenshot`, then save under `docs/images/` and reference it here. -->

## Features

- **Smart Schedule** — daily/weekly views, next-class card (auto-refreshes every 60s), manual course CRUD, CSV/ICS import with preview and conflict detection.
- **Deadline Tracker** — assignments and exams with countdowns and T-24h / T-1h reminders (Android); due dates default to 23:59 with an optional time-of-day (e.g. a 09:00 exam).
- **GPA Calculator** — per-semester and cumulative GPA across 4.0 / 4.3 / 5.0 / percentage / custom scales; honors +0.5 capped at the scale max; invalid grades are skipped with a count; what-if planning.
- **Campus Finder** — searchable offline room list (local JSON + static map stub). Search input is trimmed automatically.

## Prerequisites

- [Flutter 3.27.4](https://docs.flutter.dev/release/archive) (pinned in CI)
- [Git](https://git-scm.com/)
- Android Studio or Android SDK for Android builds; Visual Studio C++ toolchain for Windows builds

## Clone, Install, Run

```bash
git clone https://github.com/v0idjs/UniPilot.git
cd UniPilot
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test --coverage
flutter run -d windows   # or: flutter run -d android
```

Run a single test file:

```bash
flutter test test/path/to_test.dart
```

See [docs/installation.md](docs/installation.md) for platform setup and troubleshooting.

## Configuration

No environment variables or `.env` file needed — UniPilot is fully offline and uses no API keys or backend services.

The only secrets involved are for **Android release signing** in CI (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`). Contributors building locally don't need them. Maintainers, see [docs/release.md](docs/release.md).

## Project Structure

```
lib/main.dart                        # entrypoint → lib/app.dart
lib/app.dart                         # UniPilotApp, go_router shell with 4 tabs
lib/features/schedule/               # schedule UI + logic
lib/features/deadlines/              # deadline UI + logic
lib/features/gpa/                    # GPA UI + logic
lib/features/campus/                 # campus finder UI + logic
lib/core/db/                         # Drift/SQLite source of truth + validation
lib/core/import/                     # CSV/ICS parsers (caps: 512KB, 2000 CSV rows,
                                     # 1000 ICS events, 52 recurrences)
lib/core/notifications/              # NotificationService (exists, no callers yet)
lib/core/theme/                      # brand theme (indigo #1E1B4B, amber #F4A300)
lib/core/utils/                      # shared helpers
lib/widgets/                         # reusable widgets (e.g. NextClassCard)
assets/logo.svg                      # brand mark / launcher icon source
assets/samples/                      # CSV/ICS fixtures
assets/campus/                       # bundled offline campus data
test/                                # mirrors lib/ (unit + widget tests)
test/fakes/fake_database.dart        # fake DB for widget tests (always use this)
```

## Development

| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate Drift code (run after any DB model change, before analyze/test) |
| `dart format .` | Format code |
| `flutter analyze` | Static analysis |
| `flutter test --coverage` | Full test suite with coverage (target 80%+) |
| `flutter test test/path/to_test.dart` | Run one test file |
| `flutter run -d windows` | Run on Windows (or `-d android`) |

Rules that matter: widget tests must use `test/fakes/fake_database.dart` (never real Drift — its streams hang the widget-test clock); validation lives in the DB layer (`AppDatabase.create*` throws `ArgumentError`); commits follow Conventional Commits (`feat:`, `fix:`, `docs:`, …). Full workflow: [docs/development.md](docs/development.md).

## Deployment

Tag `v*` triggers the `Release UniPilot` workflow (universal APK + Windows zip + auto release notes). See [docs/release.md](docs/release.md).

## Contributing

PRs against `main` are welcome — please add tests. See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

MIT — see [LICENSE](LICENSE).

## Docs

- [Installation](docs/installation.md) — setup, first run, troubleshooting
- [Architecture](docs/architecture.md) — entrypoints, layers, data flow
- [Development](docs/development.md) — TDD workflow, commits, PRs, CI
- [FAQ](docs/faq.md) — offline model, build_runner, fake DB, releases
- [Import format](docs/import-format.md) — CSV/ICS columns and limits
- [Release guide](docs/release.md) — tagging, signing, publishing
- [Windows guide](docs/windows.md) — setup and troubleshooting
- [Security policy](SECURITY.md) — SQLite is unencrypted (accepted risk)
- [Changelog](CHANGELOG.md) — release history

> Note: `docs/adr/` and `docs/testing/` are local working notes and are not committed.
