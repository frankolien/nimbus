import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A section title with an optional trailing action (e.g. "See all").
class SectionHead extends StatelessWidget {
  const SectionHead({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: NB.font(16.5, weight: FontWeight.w800, letterSpacing: -0.3)),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(actionLabel!,
                style: NB.font(12.5, weight: FontWeight.w700, color: NB.orange)),
          ),
      ],
    );
  }
}
