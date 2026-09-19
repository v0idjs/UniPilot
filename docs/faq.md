# FAQ

## Is UniPilot fully offline?

Yes. All data lives in local SQLite via Drift. There is no backend, no network code, and no account system.

## Is there a backend or auth?

No. No server, no sync, no login. CSRF/XSS/auth/rate-limiting concerns don't apply — there is nothing to call.

## Do I need a `.env` file or API keys?

No. There are no environment variables and no keys. Clone, `flutter pub get`, codegen, run.

## Why must I run `build_runner` after DB changes?

Drift generates type-safe code (`.g.dart`) from your table definitions. After touching tables or DB models, the generated files are stale until you rerun:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Always rerun it **before** `flutter analyze` / `flutter test`, or you'll chase phantom errors.

## Why do widget tests use a fake database?

Real Drift query streams keep listening in a way that hangs the widget-test fake clock, freezing tests. `test/fakes/fake_database.dart` mirrors `AppDatabase` (including its `ArgumentError` validation guards) without real streams, so widget tests stay fast and deterministic.

## CI passed but `flutter analyze` shows warnings — is that OK?

CI currently runs analyze as non-failing (`|| true`), so warnings won't block a merge. Still fix any new warnings your change introduced — treat a clean `flutter analyze` as part of done.

## Is my data encrypted?

No. Local SQLite is **unencrypted** — an accepted risk documented in [SECURITY.md](../SECURITY.md). Anyone with file access to your device can read the database file.

## Do deadline notifications work yet?

Not yet. `NotificationService` exists but has no callers, so no reminders are scheduled. The T-24h / T-1h design is captured in [adr/002-notifications.md](adr/002-notifications.md); wiring it up is future work.

## How do releases work?

Push a tag matching `v*` (e.g. `v0.5.0`) and the `Release UniPilot` workflow builds a universal APK plus a Windows zip and publishes GitHub release notes extracted from [CHANGELOG.md](../CHANGELOG.md). Details: [release.md](release.md).

## Which Flutter version should I use?

Flutter **3.24.0** (Dart >= 3.5) — that's what CI pins. A different Flutter may work, but if you see odd build or analyzer behavior, downgrade/upgrade to 3.24.0 first.
