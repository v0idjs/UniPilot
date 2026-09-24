# Installation

How to get UniPilot running on your machine for development.

## Prerequisites

- **Flutter 3.47.5** — pinned in CI (`.github/workflows/ci.yml`). Check yours with `flutter --version`. If it differs, install 3.47.5 from the [Flutter release archive](https://docs.flutter.dev/release/archive).
- **Git** — for cloning.
- **Dart >= 3.13** — comes bundled with Flutter 3.47.5.
- For Android runs: Android Studio (or Android SDK + an emulator/device).
- For Windows runs: a Windows machine with the Visual Studio C++ desktop toolchain.

## Clone

```bash
git clone https://github.com/v0idjs/UniPilot.git
cd UniPilot
```

## Setup (exact order)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test --coverage
```

## First run

Android:

```bash
flutter run -d android
```

Windows:

```bash
flutter run -d windows
```

Single test file:

```bash
flutter test test/path/to_test.dart
```

## Troubleshooting

### Stale `.g.dart` errors after a DB change

If you touched tables or DB models and `analyze`/`test` report stale generated code, rerun codegen **before** anything else:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test --coverage
```

### Missing `android/` or `windows/` platform scaffold

If a platform directory is missing or corrupted, regenerate it from the project root (this only rewrites the scaffold, not `lib/`):

```bash
flutter create --platforms=android,windows .
```

Then re-run the setup sequence above.

### Launcher icons out of date

Icons are generated from `assets/logo.svg` via `flutter_launcher_icons`. After changing the logo or icon config in `pubspec.yaml`:

```bash
dart run flutter_launcher_icons
```

### Still stuck?

- See [faq.md](faq.md) for common questions (offline model, fake DB, analyzer warnings).
- See [windows.md](windows.md) for the Windows troubleshooting runbook.
- See [CONTRIBUTING.md](../CONTRIBUTING.md) for the contributor workflow.
