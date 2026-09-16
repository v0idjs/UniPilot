import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/colors.dart';

/// Desktop window defaults shared by startup and tests.
///
/// The background must stay opaque. A transparent background previously
/// produced a transparent window with no visible content on Windows.
WindowOptions buildDesktopWindowOptions() {
  return const WindowOptions(
    size: Size(1280, 800),
    center: true,
    backgroundColor: AppColors.backgroundLight,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'UniPilot',
  );
}
