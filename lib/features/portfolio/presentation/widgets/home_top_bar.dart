import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// Top bar of the wallet tab: account avatar + (editable) name, support and
/// scan actions.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.accountName,
    required this.onEditName,
    required this.onSupport,
    required this.onScan,
  });

  final String accountName;
  final VoidCallback onEditName;
  final VoidCallback onSupport;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: onEditName,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _AccountAvatar(),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    accountName,
                    overflow: TextOverflow.ellipsis,
                    style: NB.font(16, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: NB.text2),
              ],
            ),
          ),
        ),
        const Spacer(),
        _CircleIconButton(icon: Icons.headset_mic_outlined, onTap: onSupport),
        const SizedBox(width: 10),
        _CircleIconButton(icon: Icons.qr_code_scanner, onTap: onScan),
      ],
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NB.orangeHi, Color(0xFF7A45F0)],
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
