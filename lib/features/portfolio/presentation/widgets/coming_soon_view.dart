import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// Placeholder body for navigation tabs that aren't built yet.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, color: NB.text3, size: 40),
            const SizedBox(height: 12),
            Text('$label coming soon',
                style: NB.font(15, weight: FontWeight.w700, color: NB.text2)),
          ],
        ),
      ),
    );
  }
}
