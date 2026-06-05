import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A recipient row (recent or saved): a gradient avatar with the leading
/// initial, a title, a truncated address, and an optional trailing widget.
class RecipientTile extends StatelessWidget {
  const RecipientTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            _Avatar(seed: title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NB.font(15, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: NB.font(12.5, color: NB.text2)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.seed});
  final String seed;

  @override
  Widget build(BuildContext context) {
    final initial = seed.trim().isEmpty ? '?' : seed.trim().substring(0, 1).toUpperCase();
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NB.orangeHi, Color(0xFF7A45F0)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(initial,
          style: NB.font(15, weight: FontWeight.w800, color: Colors.white)),
    );
  }
}
