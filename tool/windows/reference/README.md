# Windows runner template captures (Flutter 3.47.5)

Byte-identical copies of the files the GitHub runner scaffolds via
`flutter create --platforms android,windows --project-name unipilot
--org com.unipilot .` (release.yml "Ensure platforms exist"), captured
2026-10 with the pinned SDK (3.47.5 stable, framework revision
6a19cca564, engine af7e796e16).

Purpose: the release workflow's runner patches (renderer fallback in
`main.cpp`, brand background in `win32_window.cpp`, future #17
watchdog/WARP-shim wiring) are fail-loud against template drift — these
reference copies are what the anchors were written against. Regenerate
via the `Windows Runner Templates Probe` workflow to diff against a
newer SDK before trusting stale anchors.

Contents mirror the scaffold paths:
- `runner/main.cpp` — contains the `set_dart_entrypoint_arguments`
  anchor (line 25) used by every main.cpp patch step.
- `runner/CMakeLists.txt` — source list for the runner target;
  new runner sources must be added here.
- `CMakeLists.txt` — project-level; defines `BINARY_NAME "unipilot"`,
  `/W4 /WX` strictness, install rules (the zip contents).

Prerequisite note: these are captures of the pristine template — the
live scaffolded tree gets CI patches applied on top (Impeller-switch
fallback block after the anchor, brand-indigo brush in
`win32_window.cpp`). Do not hand-edit the captures.
