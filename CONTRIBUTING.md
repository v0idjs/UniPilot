# Contributing to UniPilot

Thanks for considering contributing! This is a student-focused, offline-first Flutter app.

## Quick Start
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
flutter run -d windows   # or android
```

## Workflow
1. Fork → branch `feat/my-feature`
2. Write tests first (TDD, 80%+ coverage)
3. `dart format .` + `flutter analyze`
4. Commit with Conventional Commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
5. PR against `main` — CI must pass (analyze + test)

## Project Conventions
- Immutability: never mutate, spread (`{...user, name}`)
- File size <800 lines, feature folders under `lib/features/`
- Drift is source of truth (offline-first) — no network required

## Release
Tag `v*` triggers `Release UniPilot` workflow (APK + Windows + GitHub Release). See `docs/release.md`.

## Code of Conduct
Be kind and constructive. See `CODE_OF_CONDUCT.md`.
