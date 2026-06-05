import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../activity/presentation/pages/activity_screen.dart';
import '../../../discovery/presentation/pages/discovery_tab.dart';
import '../../../settings/presentation/pages/settings_tab.dart';
import '../widgets/coming_soon_view.dart';
import '../widgets/home_bottom_nav.dart';
import 'wallet_tab.dart';

/// App shell: the realtime wallet plus the bottom-navigation chrome. Each tab's
/// body lives in its own widget; this file just owns the navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _items = [
    NavItem(Icons.account_balance_wallet, 'Wallet'),
    NavItem(Icons.receipt_long, 'History'),
    NavItem(Icons.savings_outlined, 'Stake'),
    NavItem(Icons.explore_outlined, 'Discover'),
    NavItem(Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NB.bg,
      body: IndexedStack(
        index: _tab,
        children: const [
          WalletTab(),
          ActivityScreen(),
          ComingSoonView(label: 'Stake'),
          DiscoveryTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        items: _items,
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}
