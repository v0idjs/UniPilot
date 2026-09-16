import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brand logo is the exact icon source for Android and Windows', () {
    final logo = File('assets/logo.svg').readAsStringSync();
    expect(logo, contains('#1E1B4B'));
    expect(logo, contains('#F4A300'));

    // Raster used by legacy/Windows icon generation must exist and
    // must be derived from the exact logo above (do not hand-edit).
    expect(File('assets/icon/app_icon.png').existsSync(), isTrue);

    final config = File('flutter_launcher_icons.yaml').readAsStringSync();
    expect(config, contains('assets/icon/app_icon.png'));
    // Android adaptive foreground must reference the exact vector source.
    expect(config, contains('assets/logo.svg'));
  });
}
