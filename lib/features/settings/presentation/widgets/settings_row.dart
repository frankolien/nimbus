import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A single tappable settings row: an accent-tinted leading icon, a label (with
/// optional subtitle), an optional trailing badge/value, and a chevron. Place
/// inside a [SettingsSection]; the section draws the dividers.
class SettingsRow extends StatefulWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
    this.accent = NB.orange,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;

  /// Short trailing value shown before the chevron, e.g. a count or "All".
  final String? badge;
  final Color accent;

  /// Replaces the default chevron (e.g. a switch) when provided.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Renders the label in the destructive color.
  final bool danger;

  @override
  State<SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<SettingsRow> {
  bool _pressed = false;

  void _set(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final hasSub = widget.subtitle != null;
    final labelColor = widget.danger ? NB.red : NB.text;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? NB.surface2 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(widget.icon, size: 22, color: widget.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label,
                      style: NB.font(16.5,
                          weight: hasSub ? FontWeight.w700 : FontWeight.w600,
                          color: labelColor)),
                  if (hasSub) ...[
                    const SizedBox(height: 2),
                    Text(widget.subtitle!,
                        style: NB.font(13, color: NB.text2)),
                  ],
                ],
              ),
            ),
            if (widget.badge != null) ...[
              Text(widget.badge!,
                  style: NB.font(15, weight: FontWeight.w600, color: NB.text2)),
              const SizedBox(width: 8),
            ],
            widget.trailing ??
                const Icon(Icons.chevron_right, size: 22, color: NB.text3),
          ],
        ),
      ),
    );
  }
}
