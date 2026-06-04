import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/domain/entities/network.dart';
import 'account_avatar.dart';

/// The profile card at the top of Settings: account avatar (with the chains it
/// spans), the account label, and its primary address. Tapping drills into
/// account management.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.chains,
    required this.onTap,
  });

  final String label;

  /// Secondary line — the primary address, already shortened for display.
  final String subtitle;
  final List<Network> chains;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NB.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NB.border),
        ),
        child: Row(
          children: [
            AccountAvatar(label: label, size: 52, chains: chains),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NB.font(18, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: NB.font(13.5, color: NB.text2)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: NB.text3),
          ],
        ),
      ),
    );
  }
}
