import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// Brief "Coming soon" toast for settings rows that aren't wired up yet. Keeps
/// the placeholder feedback identical everywhere instead of re-declaring it.
void showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: NB.surface2,
      behavior: SnackBarBehavior.floating,
      content: Text('Coming soon', style: NB.font(13, color: NB.text)),
      duration: const Duration(seconds: 1),
    ),
  );
}
