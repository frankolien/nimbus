import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/chain_dots.dart';
import '../../../wallet/domain/entities/network.dart';

/// Top bar of the wallet tab: an account / all-chains selector pill on the left
/// and a single eye toggle (hide/show balance) on the right.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.accountName,
    required this.chains,
    required this.balanceHidden,
    required this.onTapAccount,
    required this.onToggleBalance,
  });

  final String accountName;

  /// Chains the active account spans, shown as overlapping logos in the pill.
  final List<Network> chains;

  /// Whether balances are currently masked — drives the eye icon.
  final bool balanceHidden;

  final VoidCallback onTapAccount;
  final VoidCallback onToggleBalance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Fills the row so the eye sits flush right; the pill hugs its content
        // on the left and ellipsizes a long name rather than overflowing.
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _AccountPill(
              name: accountName,
              chains: chains,
              onTap: onTapAccount,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _CircleIconButton(
          icon: balanceHidden
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onTap: onToggleBalance,
        ),
      ],
    );
  }
}

class _AccountPill extends StatelessWidget {
  const _AccountPill({
    required this.name,
    required this.chains,
    required this.onTap,
  });

  final String name;
  final List<Network> chains;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: NB.surface2,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chains.isNotEmpty) ...[
              ChainDots(networks: chains, size: 20, ring: NB.surface2),
              const SizedBox(width: 9),
            ],
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: NB.font(15.5, weight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: ' · All Chains',
                      style: NB.font(15.5,
                          weight: FontWeight.w500, color: NB.text2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: NB.text2),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(color: NB.surface2, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: NB.text),
      ),
    );
  }
}
