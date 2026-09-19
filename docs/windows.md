# Windows Guide

## Prerequisites

- Flutter SDK 3.27.x on `PATH` (`flutter --version`)
- Visual Studio 2022 with the Desktop C++ workload
- `flutter config --enable-windows-desktop`

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

## Build

```bash
flutter build windows --release
```

The standalone bundle lands under `build/windows/x64/runner/Release`.
Release automation zips it as `unipilot-windows.zip` — see
`docs/release.md`.

## White-screen checklist

If the window opens but stays blank:

1. Confirm the window background is opaque (desktop options use the
   branded light background, never transparent).
2. Startup paints content before initializing window APIs, so a failing
   window call degrades to a working app instead of a blank screen.
3. The local database file lives in the app documents directory; a
   corrupt `unipilot_db.sqlite` there can be deleted to start fresh.
4. Run `flutter clean` followed by `flutter pub get` when switching
   toolchains or after generated-code changes.

## Notifications on Windows

Deadline reminders do not fire on Windows yet. The plugin version with
Windows toast support crashes this project's AOT compiler (verified on
Flutter 3.24 and 3.27), so notifications stay Android-only until the
toolchain catches up — tracked as a follow-up issue. Saving, completing,
and deleting deadlines all work normally on Windows; only the toast is
missing.

## Icons

The launcher icon derives from the exact brand vector at
`assets/logo.svg`. The 1024 raster at `assets/icon/app_icon.png` is
generated from it and must not be hand-edited; platform icons are
produced by the launcher-icons step in the release workflow.
