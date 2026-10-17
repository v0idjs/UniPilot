# Windows runner template captures (Flutter 3.47.5)

Byte-identical copies of the files the GitHub runner scaffolds via
`flutter create --platforms android,windows --project-name unipilot
--org com.unipilot .` (release.yml "Ensure platforms exist"), captured
2026-10-16 from the `Windows Runner Templates Probe` run
38973019701 — the pristine template as GitHub CI sees it, before any
release.yml patch steps run.

> Capture caveat: a locally scaffolded `windows/` tree may carry
> release.yml patches applied by earlier builds (the `#17` renderer
> fallback block in `main.cpp`, the brand-indigo brush in
> `win32_window.cpp`) — `flutter create` preserves existing files.
> Only the CI probe output counts as pristine evidence.

Purpose: the release workflow's runner patches (renderer fallback in
`main.cpp`, brand background in `win32_window.cpp`, future #17
watchdog/WARP-shim wiring) are fail-loud against template drift — these
reference copies are what the anchors were written against. Regenerate
via the probe workflow and `fc` against these files before trusting
stale anchors.

Contents mirror the scaffold paths:
- `runner/main.cpp` — pristine, 43 lines. Contains the
  `project.set_dart_entrypoint_arguments(std::move(command_line_arguments));`
  anchor at line 25 (the string every main.cpp patch step checks; the
  fail-loud regexes stay valid against 3.47.5).
- `runner/CMakeLists.txt` — source list for the runner target
  (`add_executable` lines 9-17); new runner sources must be added here.
  Flutter's CMake template itself is unpatched by the current workflow,
  so the CI capture and local template match byte-for-byte.
- `CMakeLists.txt` — project-level; defines `BINARY_NAME "unipilot"`,
  `/W4 /WX` strictness (line 42), install rules (the zip contents).
- `audit/` — dumpbin evidence from probe run 38973019701
  (windows-2022, MSVC 14.29.30159), see below.

## dumpbin audit summary (run 38973019701, 2026-10-16)

`flutter_windows.dll` (release build of app bundle):

- **`d3d11.dll` is NOT statically imported** — zero matches for
  `d3d11.dll|d3d12.dll|D3D11CreateDevice` in
  `audit/d3d11-imports.txt`. ANGLE resolves d3d11 at runtime through
  the loader (`LoadLibraryA/ExA/ExW/W` are among its kernel imports),
  which is the load path a directory-placed proxy `d3d11.dll` shim
  intercepts. Nothing needs the import table satisfied for d3d11, so a
  proxy cannot break static resolution; it only has to serve the
  exports ANGLE asks for via `GetProcAddress`.
- **`dxgi.dll` IS statically imported** with exactly two functions:
  `CreateDXGIFactory` (ord 3, line 592) and `CreateDXGIFactory1`
  (ord 4, line 593). Adapter enumeration goes through the real system
  dxgi; when the shim forces WARP it overrides the ensuing
  `D3D11CreateDevice` call to `adapter = nullptr` +
  `D3D_DRIVER_TYPE_WARP`, bypassing enumeration — so a dxgi shim is
  not expected to be necessary (verify with Process Monitor on the
  affected machine).
- Full dependents list (verbatim in `audit/d3d11-dependents.txt`):
  ADVAPI32.dll, IPHLPAPI.DLL, ole32.dll, OLEAUT32.dll, PSAPI.DLL,
  SHLWAPI.dll, RPCRT4.dll, WINMM.dll, WS2_32.dll, IMM32.dll,
  USER32.dll, OPENGL32.dll, bcrypt.dll,
  api-ms-win-core-path-l1-1-0.dll, ntdll.dll, GDI32.dll, KERNEL32.dll,
  CRYPT32.dll, UIAutomationCore.DLL, OLEACC.dll, PROPSYS.dll,
  dxgi.dll, d3d9.dll, api-ms-win-core-synch-l1-2-0.dll, dwmapi.dll,
  dbghelp.dll. Notably **`d3d9.dll` is also statically imported**
  (ANGLE's legacy D3D9 module compiled in) — the WARP-forced d3d11
  path does not touch it, so it stays resolved from System32 as usual.
- Delay-load imports: dbghelp only (`SymCleanup`, `SymInitialize`,
  `SymSetOptions`, `EnumerateLoadedModulesEx`) — nothing GPU-related,
  so no delay-load shim surface.
- System `C:\Windows\System32\d3d11.dll` export table: **63 exports**
  (verbatim in `audit/d3d11-exports.txt`). The two the current shim
  design intercepts:
  - `D3D11CreateDevice` — hint 22, ordinal 6, RVA `0004A660`
  - `D3D11CreateDeviceAndSwapChain` — hint 23, ordinal 7, RVA
    `0004A7E0`
  If a Process Monitor session on the affected machine shows ANGLE
  resolving anything beyond these two, generate pass-through stubs for
  all 63 exports from `audit/d3d11-exports.txt` rather than
  hand-picking (the export dump in the artifact is the stub source).
