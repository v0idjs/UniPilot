import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The UniPilot brand mark, rendered from the canonical vector source.
///
/// Used in app bars, empty states, and dialogs so the in-app identity
/// always matches the launcher icon.
class BrandLogo extends StatelessWidget {
  final double size;
  final String semanticLabel;
  const BrandLogo({
    super.key,
    this.size = 32,
    this.semanticLabel = 'UniPilot logo',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          'assets/logo.svg',
          width: size,
          height: size,
          placeholderBuilder: (context) => SizedBox(
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}
