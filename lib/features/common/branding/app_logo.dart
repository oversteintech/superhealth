import 'package:flutter/material.dart';

import 'branding_assets.dart';

/// SuperHealth unique monogram mark.
///
/// Renders the store-quality S+ monogram on any surface at a fixed square
/// size. Falls back to a generic apps glyph if the asset is missing so the
/// login / splash / profile chrome still renders cleanly.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BrandingAssets.monogramStore,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Icon(Icons.apps, size: size * 0.7),
    );
  }
}
