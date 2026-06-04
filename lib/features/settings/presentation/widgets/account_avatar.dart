import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/domain/entities/network.dart';
import 'chain_dots.dart';

/// A circular account avatar: a brand-gradient disc with the account's initial,
/// optionally overlaid with the chains it spans at the bottom-right.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.label,
    this.size = 52,
    this.chains = const [],
  });

  final String label;
  final double size;

  /// Chains to stack at the bottom-right; empty hides the overlay.
  final List<Network> chains;

  String get _initial {
    final t = label.trim();
    return t.isEmpty ? '?' : t.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [NB.orangeHi, Color(0xFF7A45F0)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initial,
              style: NB.font(size * 0.42, weight: FontWeight.w800),
            ),
          ),
          if (chains.isNotEmpty)
            Positioned(
              right: -3,
              bottom: -2,
              child: ChainDots(networks: chains, size: size * 0.34),
            ),
        ],
      ),
    );
  }
}
