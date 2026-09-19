<!--
  Thanks for contributing to UniPilot! Please fill in the sections below.
  PRs must target `main` and pass CI (analyze + tests).
-->

## Description

<!-- What does this PR change, and why? Link related issues: Fixes #123 -->

## Changes

- <!-- e.g. feat: add semester GPA trend chart -->

## Testing

<!-- How did you verify this? Commands run, devices/emulators tested. -->

- [ ] `dart run build_runner build --delete-conflicting-outputs` (if DB/models changed)
- [ ] `dart format .`
- [ ] `flutter analyze` — no new warnings
- [ ] `flutter test --coverage` — all green
- [ ] Widget tests use `test/fakes/fake_database.dart` (not real Drift) and `test/fakes/fake_reminder_scheduler.dart` (not the real notification plugin)

## Checklist

- [ ] Tests added first (TDD) or updated; coverage stays 80%+
- [ ] New validation guards added to `lib/core/db/validation.dart` (shared by the real DB and the fake — never inline them)
- [ ] No hardcoded secrets; inputs validated at UI **and** DB layers
- [ ] Follows Conventional Commits (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`)
- [ ] Docs updated if behavior changed (`README.md`, `docs/`, `CHANGELOG.md` under `Unreleased`)
