import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot/widgets/brand_logo.dart';

class _SvgBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">'
        '<circle cx="50" cy="50" r="45" fill="#1E1B4B"/></svg>';
    return ByteData.view(Uint8List.fromList(utf8.encode(svg)).buffer);
  }
}

void main() {
  testWidgets('renders the brand mark with semantics and size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultAssetBundle(
          bundle: _SvgBundle(),
          child: const BrandLogo(size: 40),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      find.bySemanticsLabel('UniPilot logo'),
      findsOneWidget,
    );
    final sized = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byType(SvgPicture),
        matching: find.byType(SizedBox),
      ).first,
    );
    expect(sized.width, 40);
  });
}
