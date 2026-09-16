import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/core/window/desktop_window.dart';

void main() {
  test('desktop window is opaque with content-visible defaults', () {
    final options = buildDesktopWindowOptions();

    // Regression: transparent background produced a transparent window
    // with no visible content on Windows (issue #1).
    expect(options.backgroundColor, isNot(Colors.transparent));
    expect(options.backgroundColor?.alpha, 0xFF);
    expect(options.size, const Size(1280, 800));
    expect(options.center, isTrue);
    expect(options.title, 'UniPilot');
  });
}
