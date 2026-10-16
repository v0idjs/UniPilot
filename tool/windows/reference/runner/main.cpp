#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  // UniPilot renderer fallback (issue #17): honor UNIPILOT_RENDERER=software
  // or a --software flag, and auto-fallback on RDP sessions where the GPU
  // presentation path is unreliable. Falls back to Skia; the default stays
  // Impeller for everyone else. NOTE: this changes the renderer backend,
  // not full software rasterization -- this SDK's embedder API exposes no
  // generic engine-switches knob, so --enable-software-rendering cannot be
  // passed through. See docs/windows-legacy-gpu.md.
  {
    const std::wstring args(command_line != nullptr ? command_line : L"");
    // Matches a standalone --software token only (space- or
    // quote-delimited): the runner also forwards CLI args to Dart,
    // so a substring check could misfire on a future Dart flag.
    // ASCII codes below: 32 = space, 34 = double quote.
    const auto hasSoftwareFlag = [](const std::wstring& cmd) {
      const std::wstring flag = L"--software";
      size_t pos = 0;
      while ((pos = cmd.find(flag, pos)) != std::wstring::npos) {
        const bool leftOk =
            (pos == 0) || (cmd[pos - 1] == 32 || cmd[pos - 1] == 34);
        const size_t end = pos + flag.size();
        const bool rightOk =
            (end >= cmd.size()) || (cmd[end] == 32 || cmd[end] == 34);
        if (leftOk && rightOk) {
          return true;
        }
        pos += flag.size();
      }
      return false;
    };
    bool software = hasSoftwareFlag(args);
    wchar_t renderer_env[32] = {};
    if (::GetEnvironmentVariableW(L"UNIPILOT_RENDERER", renderer_env, 32) >
        0) {
      software = software || (std::wstring(renderer_env) == L"software");
    }
    if (!software && ::GetSystemMetrics(SM_REMOTESESSION) != 0) {
      software = true;
    }
    if (software) {
      project.set_impeller_switch(flutter::ImpellerSwitch::Disabled);
    }
  }

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"unipilot", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
