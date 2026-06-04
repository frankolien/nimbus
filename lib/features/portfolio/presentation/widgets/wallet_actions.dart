import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A single circular quick-action (Buy, Send, Exchange, Receive).
class WalletAction {
  const WalletAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// The row of circular quick-actions under the balance.
class WalletActions extends StatelessWidget {
  const WalletActions({super.key, required this.actions});
  final List<WalletAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [for (final a in actions) _ActionButton(action: a)],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});
  final WalletAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(color: NB.surface2, shape: BoxShape.circle),
            child: Icon(action.icon, color: NB.text, size: 22),
          ),
          const SizedBox(height: 7),
          Text(action.label, style: NB.font(12, color: NB.text2)),
        ],
      ),
    );
  }
}
