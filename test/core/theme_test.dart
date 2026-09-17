import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/theme/app_theme.dart';
import 'package:unipilot/core/theme/colors.dart';

void main() {
  test('light theme wires brand inputs and floating snackbars', () {
    final theme = buildLightTheme();

    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
  });

  test('dark theme wires brand inputs and floating snackbars', () {
    final theme = buildDarkTheme();

    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
  });

  test('dialogs and pickers carry brand surfaces in both modes', () {
    final light = buildLightTheme();
    expect(light.dialogTheme.backgroundColor, AppColors.surfaceLight);
    expect(light.dialogTheme.surfaceTintColor, Colors.transparent);
    expect(light.datePickerTheme.backgroundColor, AppColors.surfaceLight);
    expect(
      light.timePickerTheme.dialBackgroundColor,
      AppColors.indigoPrimary,
    );

    final dark = buildDarkTheme();
    expect(dark.dialogTheme.backgroundColor, AppColors.surfaceDark);
    expect(dark.dialogTheme.surfaceTintColor, Colors.transparent);
    expect(dark.datePickerTheme.backgroundColor, AppColors.surfaceDark);
    expect(
      dark.timePickerTheme.dialBackgroundColor,
      AppColors.indigoDark,
    );
  });
}
