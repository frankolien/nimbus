import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A consistent shell for Settings sub-screens: a back chip, a large title, and
/// a scrolling body. Keeps every drill-in visually identical without repeating
/// the header in each page.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    required this.children,
    this.intro,
  });

  final String title;

  /// Optional paragraph shown under the title.
  final String? intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  _BackChip(onTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(title,
                        style: NB.font(22,
                            weight: FontWeight.w800, letterSpacing: -0.4)),
                  ),
                ],
              ),
            ),
            if (intro != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(intro!,
                    style: NB.font(13.5, color: NB.text2, height: 1.5)),
              ),
            ],
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: NB.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: NB.text),
      ),
    );
  }
}
