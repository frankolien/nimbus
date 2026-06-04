import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// Top bar for the token detail screen: back, copy, and favorite.
class TokenAppBar extends StatelessWidget {
  const TokenAppBar({
    super.key,
    required this.onBack,
    required this.onCopy,
    required this.onFavorite,
  });

  final VoidCallback onBack;
  final VoidCallback onCopy;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _chip(Icons.arrow_back_ios_new, onBack),
        Row(children: [
          _chip(Icons.copy_rounded, onCopy),
          const SizedBox(width: 10),
          _chip(Icons.star_border, onFavorite),
        ]),
      ],
    );
  }

  Widget _chip(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration:
              const BoxDecoration(color: NB.surface2, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: NB.text),
        ),
      );
}
