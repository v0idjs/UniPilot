import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/theme/app_theme.dart';

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
}
