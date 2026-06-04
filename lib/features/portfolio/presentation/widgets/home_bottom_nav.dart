import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A bottom navigation destination.
class NavItem {
  const NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// The app's bottom navigation bar.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NB.bg,
        border: Border(top: BorderSide(color: NB.border)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavButton(
              item: items[i],
              selected: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? NB.orange : NB.text3;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 24, color: color),
          const SizedBox(height: 5),
          Text(item.label, style: NB.font(11, weight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
