# Changelog

All notable changes to UniPilot. Format follows Keep a Changelog.

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

