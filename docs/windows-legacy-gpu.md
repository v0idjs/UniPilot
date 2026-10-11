# Windows on legacy GPUs (#17)

## The problem in one paragraph

On machines whose GPU/driver cannot do what Flutter 3.47's presenter
needs (notably Intel GMA / 4-Series era integrated graphics on the
WDDM 1.1 inbox driver — DirectX 10 era, no flip-model swapchain),
the app opens a responsive white window titled UniPilot and never
paints content. Dart runs fine underneath (verified: main runs, UI
builds, database works, zero errors) — frames simply cannot be
presented. v0.5.x worked because the older graphics stack tolerated
that hardware; v0.6.x (Flutter 3.27 → 3.47) does not, on **either**
renderer backend — forcing Skia was tried in v0.6.2 and the window
stayed white, which is how we know the failure is below renderer
choice, at the Direct3D present layer.

## What cannot fix it (verified, not assumed)

- Switching Impeller ↔ Skia: both present through the same
  Direct3D path; both blank on this hardware.
- Software rendering (`--enable-software-rendering`): the switch
  exists in the engine but Flutter 3.47 exposes **no** way to set it
  on Windows — not via exe flags (the runner maps them to Dart
  args), not via `DartProject` (checked: only impeller/gpu-preference
  knobs), not via the C `FlutterDesktopEngineProperties` (the old
  `switches` field is gone), not via `flutter build` flags.
- Building Windows on older Flutter: blocked by dependencies —
  go_router 18 alone requires Flutter >= 3.44, so an older SDK cannot
  resolve this pubspec, and downgrading the majors would un-ship
  features and diverge the two platforms.

## Workarounds, highest confidence first

1. **Force WARP for unipilot.exe (software D3D11).** Gives ANGLE a
   working — slow but correct — device:
   - Install the Windows SDK (for `dxcpl.exe`, the DirectX Control
     Panel), or copy `dxcpl.exe` from another machine with the SDK.
   - Run `dxcpl.exe` → Edit List → add `unipilot.exe` → tick
     **Force WARP** → Apply/OK. Run the app normally.
2. **Use the Android build.** `unipilot-android.apk` from the same
   release works fully on any Android phone, reminders included.
3. **Update the Intel driver** (Intel's last 4-Series release,
   8.15.10.2869, 2012). Low confidence — it is still WDDM 1.1, which
   lacks what the presenter needs — try only if easy.
4. **Newer hardware / current driver.** Any D3D11-capable GPU with a
   maintained driver (roughly 2012+ Intel HD, or any discrete GPU)
   runs the app normally.

## Hardware requirement (README-level)

Windows builds need a GPU/driver with working Direct3D 11
presentation (WDDM 1.2+). Pre-D3D11-era integrated graphics on inbox
drivers (Intel GMA / 4-Series and older) are not supported by the
Flutter 3.47 graphics stack.
