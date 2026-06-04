import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A grouped settings card: a rounded, bordered surface holding a column of
/// rows separated by hairline dividers. Mirrors the "grouped" style the design
/// settled on.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.children, this.title});

  final List<Widget> children;

  /// Optional small caption shown above the card.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(title!.toUpperCase(),
                style: NB.font(11.5,
                    weight: FontWeight.w700,
                    color: NB.text3,
                    letterSpacing: 0.6)),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: NB.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: NB.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, thickness: 1, color: NB.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
