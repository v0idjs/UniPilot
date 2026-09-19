# Development

## Branch and commit

- Branch from `main`: `feat/my-feature` (or `fix/…`, `docs/…`, `refactor/…`).
- Commits follow [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.

## TDD workflow (80%+ coverage)

1. Write the failing test first (RED).
2. Implement the minimal fix (GREEN).
3. Refactor with tests green.
4. Verify with `flutter test --coverage` — target 80%+ coverage.

New tests mirror the source layout under `test/`.

## The fake-DB rule

Widget tests **must** use `test/fakes/fake_database.dart` — never real Drift. Real Drift query streams hang the widget-test fake clock. The fake mirrors `AppDatabase` validation, so when you add a guard in `AppDatabase.create*`, add the same `ArgumentError` in the fake.

## Format and analyze

Run in this order before pushing:

```bash
dart format .
flutter analyze
flutter test --coverage
```

Note: CI currently runs `flutter analyze` as non-failing (`|| true`) — still run it locally and fix any new warnings you introduced.

## Pull requests

- PRs target `main`. CI runs pub get → build_runner → format check → analyze → test.
- Keep PRs focused; describe what changed and how it was tested.
- Tag `v*` (e.g. `v0.5.0`) triggers the release workflow (APK + Windows zip). See [release.md](release.md).

Related: [CONTRIBUTING.md](../CONTRIBUTING.md), [installation.md](installation.md), [architecture.md](architecture.md).
