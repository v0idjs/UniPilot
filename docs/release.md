# Release — UniPilot

## Versioning

`pubspec.yaml` version is `0.x.y+buildNumber` (for example `0.4.0+20`).
The `+buildNumber` part becomes Android `versionCode` and must always
increase, otherwise Android refuses the update. Tag `v0.x.y` triggers
the `Release UniPilot` workflow (`.github/workflows/release.yml`),
which builds one universal APK plus the Windows bundle and publishes
both to the GitHub Release.

## Workflows

- `.github/workflows/ci.yml` — analyze + test on push/PR to main.
- `.github/workflows/release.yml` — `Release UniPilot`: Android APK
  (ubuntu-latest, Flutter 3.24.0) + Windows app (windows-2022) +
  published GitHub Release with per-version notes from `CHANGELOG.md`.

## Signing (updates must keep one signature line)

Android treats an update as the same app only when `applicationId`
(`com.unipilot.unipilot`, pinned at scaffold time) **and** the signing
key both match the installed copy. A mismatch fails with a package
conflict and can only be fixed by uninstalling first.

CI runners are ephemeral: without a persistent key, every release
would be signed with a fresh debug key and no update would install.
The release workflow therefore configures signing from secrets when
present and falls back to debug signing otherwise:

1. Generate a keystore once:
   `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Encode it: `base64 upload-keystore.jks | tr -d '\n'`
3. Add repository secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
   `KEY_ALIAS`, `KEY_PASSWORD`
4. Never commit the keystore (see `.gitignore`).

If an install already conflicts (mixed debug/release history), remove
the old copy first: `adb uninstall com.unipilot.unipilot`, then
install the latest release. The APK is a single universal build, so
there is no ABI variant to pick.

## Icons

Launcher icons derive from `assets/logo.svg` via the 1024 master at
`assets/icon/app_icon.png` (do not hand-edit the PNG). The release
workflow regenerates platform icons and fails the build if the
expected outputs are missing.

## Local Build

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
flutter build apk --release
flutter build windows --release
```

See also `docs/windows.md` for the Windows runbook.
