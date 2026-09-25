import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/theme/app_theme.dart';
import 'package:unipilot/core/theme/colors.dart';

/// WCAG 2.1 contrast checks for the indigo/amber palette (#13).
///
/// Text needs >= 4.5:1 (AA); large text and UI components >= 3:1.
/// Every pair asserted here is read from the shipped ThemeData, so a
/// palette or theme regression fails the suite instead of users' eyes.
void main() {
  double luminance(Color c) {
    double channel(int v) {
      final s = v / 255.0;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    // ignore: deprecated_member_use
    return 0.2126 * channel(c.red) +
        // ignore: deprecated_member_use
        0.7152 * channel(c.green) +
        // ignore: deprecated_member_use
        0.0722 * channel(c.blue);
  }

  double ratio(Color fg, Color bg) {
    final l1 = luminance(fg);
    final l2 = luminance(bg);
    final hi = l1 > l2 ? l1 : l2;
    final lo = l1 > l2 ? l2 : l1;
    return (hi + 0.05) / (lo + 0.05);
  }

  group('light theme', () {
    late ThemeData theme;
    setUp(() => theme = buildLightTheme());

    test('app bar title (white on indigo) meets AAA', () {
      expect(
        ratio(Colors.white, AppColors.indigoPrimary),
        greaterThanOrEqualTo(7.0),
      );
    });

    test('FAB foreground on amber meets AA', () {
      final fg = theme.floatingActionButtonTheme.foregroundColor!;
      expect(ratio(fg, AppColors.amberAccent), greaterThanOrEqualTo(4.5));
    });

    test('dialog title (indigo on white) meets AAA', () {
      final fg = theme.dialogTheme.titleTextStyle!.color!;
      expect(
        ratio(fg, AppColors.surfaceLight),
        greaterThanOrEqualTo(7.0),
      );
    });

    test('date picker selected day on amber meets AA', () {
      final fg = theme.datePickerTheme.dayForegroundColor!
          .resolve({WidgetState.selected})!;
      final bg = theme.datePickerTheme.dayBackgroundColor!
          .resolve({WidgetState.selected})!;
      expect(ratio(fg, bg), greaterThanOrEqualTo(4.5));
    });

    test('body text (onBackground on surface) meets AA', () {
      expect(
        ratio(theme.colorScheme.onSurface, AppColors.surfaceLight),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('dark theme', () {
    late ThemeData theme;
    setUp(() => theme = buildDarkTheme());

    test('app bar title (white on indigoDark) meets AAA', () {
      expect(
        ratio(Colors.white, AppColors.indigoDark),
        greaterThanOrEqualTo(7.0),
      );
    });

    test('FAB foreground on amber meets AA', () {
      final fg = theme.floatingActionButtonTheme.foregroundColor!;
      expect(ratio(fg, AppColors.amberAccent), greaterThanOrEqualTo(4.5));
    });

    test('dialog content (white70 on surfaceDark) meets AA', () {
      final fg = theme.dialogTheme.contentTextStyle!.color!;
      expect(
        ratio(fg, AppColors.surfaceDark),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('date picker selected day on amber meets AA', () {
      final fg = theme.datePickerTheme.dayForegroundColor!
          .resolve({WidgetState.selected})!;
      final bg = theme.datePickerTheme.dayBackgroundColor!
          .resolve({WidgetState.selected})!;
      expect(ratio(fg, bg), greaterThanOrEqualTo(4.5));
    });

    test('body text (onBackground on surface) meets AA', () {
      expect(
        ratio(theme.colorScheme.onSurface, AppColors.surfaceDark),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
