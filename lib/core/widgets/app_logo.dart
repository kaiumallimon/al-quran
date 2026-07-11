import 'package:flutter/material.dart';

import '../constants/asset_constants.dart';
import '../theme/app_spacing.dart';

/// Reusable app logo from bundled assets.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 88,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.elevation = 0,
  });

  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);
    final image = ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        AssetConstants.logo,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => Icon(
          Icons.menu_book_rounded,
          size: size * 0.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    if (elevation <= 0) return image;

    return Material(
      elevation: elevation,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }
}
