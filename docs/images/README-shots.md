# Screenshot runbook (#15)

`flutter screenshot` and `integration_test.takeScreenshot` do **not**
support Windows desktop (verified: `MissingPluginException` for
`captureScreenshot` on `plugins.flutter.io/integration_test`, and the
tool refuses with "Screenshot not supported for Windows"). Captures
must be taken with OS tooling on a real display — headless sessions
cannot read the hardware-composited surface either.

## Steps (on a real Windows machine, ~5 minutes)

1. Install v0.6.2+ (`unipilot-windows.zip`, extract and run) or
   `flutter run -d windows --release`.
2. Seed demo content once:
   - Schedule tab → Add Course → code `CS101`, name `Intro to Testing` →
     Save. Open it → Add time slot → Monday 09:00–10:00 → Save slot.
   - Deadlines tab → Add Deadline → title `Problem set 3` → Save
     (due defaults to tomorrow 23:59).
3. Resize to 1280×800 if needed (the app opens centered at that size).
4. Capture with Win+Shift+S (or Snipping Tool), one shot per tab:
   - `docs/images/schedule.png` — Schedule with the seeded course
   - `docs/images/deadlines.png` — Deadline list
   - `docs/images/gpa.png` — GPA tab (optional)
   - `docs/images/campus.png` — Campus tab (optional)
5. Keep shots at 1280×800 PNG, commit, and close #15.

The README table already references `schedule.png` and `deadlines.png`;
images 404 until this runbook is executed.
