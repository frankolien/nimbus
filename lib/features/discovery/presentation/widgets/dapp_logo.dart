import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../data/dapp_catalog.dart';

/// A dApp's real logo in a rounded tile, with the brand monogram as a fallback
/// while loading or if the image can't be fetched. Shared by the Spotlight
/// cards and the Popular-apps rows.
class DappLogo extends StatelessWidget {
  const DappLogo({super.key, required this.dapp, required this.size, this.radius});

  final Dapp dapp;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.29;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dapp.accent,
        borderRadius: BorderRadius.circular(r),
      ),
      alignment: Alignment.center,
      child: Text(dapp.mono,
          style: NB.font(size * 0.5, weight: FontWeight.w800, color: NB.bg)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Image.network(
        dapp.logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}
