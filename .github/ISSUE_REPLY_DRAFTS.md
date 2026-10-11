# Issue reply drafts — copy-paste only, do not auto-post

## 1. Reply for #17 (blank white window)

> Thanks for the report. Please run this check with the latest
> release and tell me what happens:
>
> 1. Send your graphics and OS details first: GPU model(s) from Device
>    Manager → Display adapters, driver version/date, Windows version
>    (run `winver`), and whether you use RDP or a VM. On pre-D3D11
>    graphics (e.g. Intel GMA / 4-Series on inbox drivers) safe mode
>    will NOT help — skip to step 4.
> 2. Otherwise, close the app, then double-click
>    **`unipilot-safe-mode.bat`** (in the same folder as
>    `unipilot.exe`) and say whether the UI appears.
> 3. Attach **`unipilot-error.log`** from your documents folder:
>    `%USERPROFILE%\Documents\unipilot-error.log`
>    (same folder as `unipilot_db.sqlite`). If the file is missing,
>    say so — that is also useful information (a white window with no
>    log entry points at the presentation layer, not a Dart exception).
> 4. If safe mode stays white, the known-effective routes are Force
>    WARP for `unipilot.exe` via `dxcpl.exe`, or the Android build —
>    see `docs/windows-legacy-gpu.md`.

## 2. Status comment for #16 (Windows toasts blocked)

> Still blocked upstream. Retried on Flutter 3.47.5 with
> flutter_local_notifications 22.x: the Windows release build fails
> in the AOT step with
> `Unexpected object (Class with illegal cid, full-aot)` on
> `NativeLaunchDetails` in
> `package:flutter_local_notifications_windows/src/ffi/bindings.dart`
> (`AOT snapshotter exited with code -1073740791`), so the upgrade
> was reverted and notifications stay Android-only on plugin 17.x.
> A weekly probe (`.github/workflows/windows-notifications-probe.yml`)
> now retries the latest stable plugin against the Windows release
> build and will file a tracking issue the moment it goes green.

## 3. PR description (all three changes)

**What changed**

- Refs #17: opt-in Windows renderer fallback — `UNIPILOT_RENDERER=software`,
  a runner-level `--software` flag, or an RDP session switches the
  runner to Skia (default stays Impeller). The release zip ships
  `unipilot-safe-mode.bat`. Startup failures are logged to
  `unipilot-error.log` (`FlutterError.onError`,
  `PlatformDispatcher.onError`, `runZonedGuarded`) with a fallback UI
  instead of a blank window. Release workflow gains artifact
  assertions (safe-mode launcher present, runner patch marker present)
  plus a documented `workflow_dispatch` dry-run.
- Refs #16: retried the plugin 22.x upgrade on Flutter 3.47.5 and
  reproduced the AOT crash, so the upgrade was reverted; docs record
  the blocker and a weekly probe watches for an upstream fix.
- Refs #15: README screenshots placeholders + Download section,
  `docs/REPO_SETTINGS.md` (values only — not applied).

**Verification**

- `dart format` clean, `flutter analyze` zero errors/warnings,
  full suite green with coverage above the 80% gate.
- Patched Windows runner compiles; app launches with and without the
  fallback triggers.

**What I could not verify**

- Whether the Skia fallback actually paints on the failing
  GPU/driver — no such hardware here. Needs a maintainer run of
  `unipilot-safe-mode.bat` on the affected machine (see #17).
- The weekly probe workflow file itself (YAML reviewed, not executed).
- Screenshots and repo settings are still pending maintainer action.
