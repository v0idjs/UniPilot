# Release — UniPilot

## Versioning
`pubspec.yaml` version = `1.0.0+buildNumber`. Tag `v1.0.0` triggers builds.

## Workflows
- `.github/workflows/build-apk.yml` — ubuntu-latest, flutter 3.24.0, `flutter build apk --release --split-per-abi`, artifacts + `softprops/action-gh-release`
- `.github/workflows/build-windows.yml` — windows-latest, `flutter config --enable-windows-desktop`, `flutter build windows`, zip + release
- `.github/workflows/ci.yml` — analyze + test on push/PR to main

## Signing (v1.0 debug)
v1.0 ships debug-signed. To add release signing:
1. Generate keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Base64: `base64 upload-keystore.jks | tr -d '\n'`
3. Add GH Secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
4. Update `android/app/build.gradle` signingConfigs.

## Local Build
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
flutter build apk --release
flutter build windows --release
```
