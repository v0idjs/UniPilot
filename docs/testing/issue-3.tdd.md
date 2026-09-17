# TDD Evidence — Issue #3: install conflicts, icons, dialogs, UI

## Source plan

A planner subagent produced an orchestration plan for this issue. Its
claims were verified before use and partially rejected:

- Confirmed: `android/` and `windows/` hold only `.gitkeep`;
  `adaptive_icon_foreground` pointed at the SVG source; dialog themes
  held shape only; `assets/fonts/` is empty so the referenced display
  families silently fall back.
- Rejected: the claim that `.github/workflows/` is empty (the release
  and CI workflows exist and run); the implication that the package
  identity changes per build (the scaffold org is stable — the real
  update killer is the signature line, see below).

## User journeys

1. As a student, I want a newer release to install over my current
   one, so that updating never forces an uninstall.
2. As a student, I want launcher icons that match the brand mark, so
   that the app is recognizable.
3. As a student, I want dialogs and pickers readable in my theme, so
   that saving and picking dates never confuses me.
4. As a student, I want every tappable row to look tappable, so that
   I discover details instead of missing them.

## Task report

| Task | Summary | Validation | Outcome |
|------|---------|------------|---------|
| Reproducers (RED) | Dialog/picker surface assertions, raster-foreground config assertion, dialog brand-mark widget test | CI `35211068518`: `completed failure` — null dialog colors, SVG foreground mismatch, no dialog mark | RED for exactly the reported gaps |
| Fix (GREEN attempt) | Persistent-signing wiring, universal APK, PNG foreground, full dialog/picker themes, dialog marks, chevrons, native-bg step, docs | CI `35213616648`: 62 passed / 4 failed — `withValues`-style const error on dark `DialogTheme` (BorderRadius is not const) plus a doubled brand finder | Two defects, both diagnosed from logs |
| Compat fix | Non-const dark dialog theme, scoped dialog assertion | CI `35214555017`: `completed success` | Full suite GREEN |

Install-conflict root cause: release APKs were debug-signed on
ephemeral runners, so every release carried a fresh random key and
Android rejected updates as conflicting packages. The workflow now
configures a persistent key from secrets (the stock template consumes
`android/key.properties` automatically) with a loud fallback warning,
ships one universal APK, and keeps the version code increasing. Until
the secrets are added, debug-signed lines still conflict across
releases — documented with the uninstall escape hatch.

## Test specification

| # | Guarantee | Test | Type | Result |
|---|-----------|------|------|--------|
| 1 | Dialogs/pickers carry brand surfaces both modes | `test/core/theme_test.dart` | unit | PASS (CI `35214555017`) |
| 2 | Adaptive foreground is the PNG master, never SVG | `test/icon/logo_icon_test.dart` | unit | PASS (CI `35214555017`) |
| 3 | Deadline dialog carries the brand mark | `test/features/deadlines/deadline_dialog_brand_test.dart` | widget | PASS (CI `35214555017`) |

All earlier tests still pass unmodified (regression).

## Coverage and known gaps

- `flutter test --coverage` ran green in CI; exact percentage not
  captured, so no number is claimed.
- The persistent signing key itself must be created once and stored as
  repository secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
  `KEY_ALIAS`, `KEY_PASSWORD`); without them the documented debug
  fallback applies.
- Installs already broken by mixed-signature history need one manual
  uninstall first; then the stable line takes over.
- Display families remain undeclared because no font files ship in
  `assets/fonts/`; the stale references were removed.
- Native Windows background treatment is best-effort in CI and needs
  one on-device cold-start look.

## Merge evidence

Checkpoint commits on `main` for this task, in order:

- `4af91df` test: add reproducers for dialog theme, icon config,
  dialog branding (issue #3, RED)
- `4cd3422` fix: stable signing with universal APK, raster icon
  foreground, themed dialogs, tappable rows (issue #3, GREEN)
- `6dfb752` fix: non-const dark dialog theme and scoped dialog brand
  assertion

Each message describes its stage and evidence; all are reachable from
`HEAD` on `main`.

## Release saga (post-GREEN)

- First `v0.4.0` release run failed fast in both icon steps: the
  config still asked for iOS output while no `ios/` runner exists
  (`PathNotFoundException` on the iOS icon set). Previously swallowed
  by `|| echo`, now loud by design. Fixed by disabling iOS/Web
  outputs.
- Second run failed asymmetrically: each job scaffolds only its own
  runner, but the icon tool touches all configured platforms
  (missing `AndroidManifest.xml` on Windows and vice versa). Fixed by
  scaffolding both runners in each job.
- Third run succeeded: `v0.4.0` ships `unipilot-android.apk`
  (universal) + `unipilot-windows.zip`.
- The Windows background scan proved the native template uses a null
  brush (`hbrBackground = 0`), so no white is painted natively —
  remaining white-screen suspicion stays on first-frame/engine
  behavior, mitigated by paint-first startup plus the opaque theme.
- One manual step remains outside code: repository secrets
  (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`,
  `KEY_PASSWORD`) must be added once per `docs/release.md`; until
  then releases stay debug-signed and cross-release updates still
  conflict. Installs already broken by mixed-signature history need
  one `adb uninstall com.unipilot.unipilot` first.
