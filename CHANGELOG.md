# Changelog

All notable changes to UniPilot. Format follows Keep a Changelog.

## Unreleased
### Added
- New docs: `docs/installation.md`, `docs/architecture.md`, `docs/development.md`, `docs/faq.md`
- GitHub community files: PR template, bug report + feature request forms
- Rewritten `README.md` with badges, setup steps, project structure, and full docs index

### Changed
- `README.md` now states no `.env` is needed and points to `docs/release.md` for Android signing secrets

### Removed
- Unused dev dependencies: `mockito`, `fake_async`, `riverpod_annotation`, `riverpod_generator`, `riverpod_lint`
- Dead l10n scaffold: `l10n.yaml`, `lib/l10n/`, `flutter_localizations` dependency
- Empty `integration_test/` and `assets/fonts/` directories; Node leftovers from `.gitignore`
- `docs/adr/` and `docs/testing/` are local-only working notes (gitignored)

## v0.4.0 — 2026-09-17
### Added
- Persistent release signing so Android updates install cleanly over previous releases
- Fully themed dialogs, date pickers, and time pickers with readable brand colors in light and dark modes
- Brand mark on dialogs plus chevron affordances on every tappable row
- Branded native window background and a Windows troubleshooting runbook

### Changed
- Single universal install file per release instead of per-architecture variants
- Release pipeline now fails loudly if generated icons are missing

### Fixed
- Newer installs conflicting with the existing package on update
- Launcher generation silently skipping output due to a vector foreground
- Dialogs and pickers inheriting washed-out default surfaces
- Tappable rows giving no visual hint that they respond

## v0.3.0 — 2026-09-16
### Added
- Brand mark surfaced inside the app bar on every section, matching the launcher icon
- Responsive navigation with a side rail on wide desktop windows and a bottom bar on phones
- Branded next-class hero with live countdown and room display
- Reusable empty and error states with clear next steps and retry actions
- Completed visual system covering inputs, snackbars, navigation, dialogs, and sheets in both themes
- Startup error fallback so a widget failure renders a message instead of a blank screen
- Windows setup and troubleshooting guide

### Changed
- Placeholder cards replaced with purposeful empty states across the schedule
- Loading and failure states now share one consistent look and behavior

### Fixed
- Detail sheet and hero row overflow on compact screen sizes
- Theme API usage aligned with the pinned framework version

## v0.2.0 — 2026-09-16
### Added
- Course details with editing, deletion, and per-course weekly time slots with automatic conflict detection
- Weekly overview that renders real scheduled time slots grouped by day, with next-class highlight driven by actual data
- Deadline completion toggle directly from the list, plus detail view with completion and deletion actions
- Semester details showing computed GPA, grade management per course, and semester deletion
- Campus room details with building, floor, and notes on tap

### Changed
- Desktop startup now paints content immediately and treats window setup as best effort, so a failing window call can no longer leave a blank screen
- Every saved row across schedule, deadlines, GPA, and campus now responds to taps with details and actions

### Fixed
- List rows doing nothing when tapped across all four sections
- Desktop window staying fully white with no painted content
- Detail sheet overflow on compact screen sizes

## v0.1.0 — 2026-09-16
### Added
- Offline-first student hub with schedule management, deadline tracking, GPA calculation, and a campus directory
- Daily and weekly schedule views with next-class highlight, manual course management, and CSV/ICS import with conflict detection
- Deadline tracking with countdowns and local reminders ahead of due times
- GPA calculator with per-semester and cumulative results across multiple grading scales, including what-if planning
- Searchable campus room directory backed by bundled offline data
- Native launcher icon derived from the brand mark for Android and Windows builds
- Open-source documentation with contribution guidelines, code of conduct, and security policy

### Changed
- Desktop startup now opens a centered window with an opaque background and visible content on first paint
- Adding a course, deadline, or semester now persists offline and appears in its list immediately with confirmation feedback
- Release history consolidated into this single baseline, replacing the earlier pre-release sequence

### Fixed
- Transparent desktop window on launch that showed no content
- Saved courses, deadlines, and semesters not appearing in their lists despite a save confirmation
- Launcher icon generation now runs consistently for both mobile and desktop builds

### Removed
- Legacy pre-release tags and empty draft releases from the early setup phase
- Redundant database adapter layer in favor of the direct native driver

## v1.0.15 — 2026-09-16
### Changed
- Release notes: now per-version from `CHANGELOG.md` (extracted via `awk` in workflow) + `generate_release_notes` — each tag shows its own Added/Changed/Fixed instead of static template

### Fixed
- `README.md`: logo reduced to 140px via `<img width="140">` (was full-width `![logo]`)

## v1.0.14 — 2026-09-16
### Added
- MIT `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
- Launcher icons from `assets/logo.svg` → `assets/icon/app_icon.png` (1024) via `flutter_launcher_icons` (Android `mipmap-*` adaptive, iOS `AppIcon`, Windows `app_icon.ico`, Web)
- `flutter_svg` + `window_manager` dependencies
- Open-source badges and logo header in `README.md`

### Changed
- `.gitignore`: now ignores `.opencode-ecc/`, `AGENTS.md`, `opencode.json` and adds `*.jks`, `*.keystore`, `android/key.properties`
- `README.md`: logo reduced to 140px (`<img width="140">`), added CI/Release/License badges

### Fixed
- **Windows black screen**: `main()` → `Future<void> main() async` with `windowManager.ensureInitialized()` + `WindowOptions(1280x800, center:true)`; `GoRouter` `errorBuilder`; `notification_service` guarded for Windows with `try/catch`
- **Android FABs**: `ScheduleScreen`, `DeadlineListScreen`, `GpaScreen` `onPressed: () {}` → functional `showModalBottomSheet`/`AlertDialog` with `SnackBar` feedback and form validation

## v1.0.13 — 2026-09-15
### Added
- Unified `Release UniPilot` workflow (Android SDK 35 + Kotlin 1.9.22 + AGP 8.5 + Gradle 8.7, NDK 26, `coreLibraryDesugaring`)
- `windows-2022` + `CMAKE_GENERATOR VS 17 2022`

### Fixed
- Android `compileSdk 34 → 35` + `buildTools 35.0.0` + corrupted `android.jar` reinstall
- Kotlin `1.7.10 → 1.9.22` and desugaring `desugar_jdk_libs:2.1.4` (Groovy `'` syntax)

### Assets
- 3 APK splits (`arm64-v8a`, `armeabi-v7a`, `x86_64`) + `unipilot-windows.zip` with auto release notes

## v1.0.0 — 2026-09-15
### Added
- **Bootstrap**: Flutter 3.24, Drift/SQLite, Riverpod, go_router, amber #F4A300 + indigo #1E1B4B
- **Features**: Schedule (CSV/ICS + conflict), Deadlines (countdown + notifications), GPA (4.0/4.3/5.0), Campus stub, Offline-first

