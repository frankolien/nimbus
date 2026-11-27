import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/chain_dots.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/settings_feedback.dart';
import '../widgets/settings_profile_card.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_section.dart';
import '../widgets/wallet_removal.dart';
import 'appearance_screen.dart';
import 'manage_accounts_screen.dart';
import 'network_screen.dart';
import 'security_screen.dart';

/// The Settings tab: a searchable, grouped list with a profile card, tinted
/// rows, a remove-wallet button, and a version footer. Rows with real backing
/// (account, security, network) drill in; the rest show "coming soon".
class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  // Representative chains for an account, most prominent first.
  static const _chainOrder = [
    ChainFamily.solana,
    ChainFamily.evm,
    ChainFamily.bitcoin,
    ChainFamily.sui,
  ];

  List<Network> _chainsOf(WalletAccount a) => [
        for (final f in _chainOrder)
          if (a.account(f) != null) ChainDots.representative(f),
      ];

  String _primaryAddress(WalletAccount a) =>
      a.account(ChainFamily.solana)?.address ?? a.accounts.first.address;

  List<List<_Item>> _groups() {
    return [
      [
        _Item(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Account',
          accent: NB.orange,
          onTap: () => _push(const ManageAccountsScreen()),
        ),
        _Item(
          icon: Icons.tune,
          label: 'Preferences',
          accent: NB.orange,
          onTap: () => showComingSoon(context),
        ),
        _Item(
          icon: Icons.wallpaper,
          label: 'Appearance',
          accent: NB.pink,
          onTap: () => _push(const AppearanceScreen()),
        ),
        _Item(
          icon: Icons.shield_outlined,
          label: 'Security & Privacy',
          accent: NB.green,
          onTap: () => _push(const SecurityScreen()),
        ),
      ],
      [
        _Item(
          icon: Icons.public,
          label: 'Network',
          accent: NB.blue,
          badge: 'Devnet',
          onTap: () => _push(const NetworkScreen()),
        ),
        _Item(
          icon: Icons.contacts_outlined,
          label: 'Address Book',
          accent: NB.violet,
          onTap: () => showComingSoon(context),
        ),
        _Item(
          icon: Icons.layers_outlined,
          label: 'Connected Apps',
          accent: NB.pink,
          onTap: () => showComingSoon(context),
        ),
        _Item(
          icon: Icons.notifications_none,
          label: 'Notifications',
          accent: NB.orange,
          onTap: () => showComingSoon(context),
        ),
      ],
      [
        _Item(
          icon: Icons.terminal,
          label: 'Developer Settings',
          accent: NB.text2,
          onTap: () => showComingSoon(context),
        ),
      ],
      [
        _Item(
          icon: Icons.help_outline,
          label: 'Help & Support',
          accent: NB.orange,
          onTap: () => showComingSoon(context),
        ),
        _Item(
          icon: Icons.favorite_border,
          label: 'Invite your friends',
          accent: NB.orange,
          onTap: () => showComingSoon(context),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(walletSessionProvider);
    final account = session.activeAccount;
    final searching = _query.isNotEmpty;

    final groups = [
      for (final g in _groups())
        [for (final i in g) if (i.matches(_query)) i],
    ].where((g) => g.isNotEmpty).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Text('Settings',
                style: NB.font(28, weight: FontWeight.w800, letterSpacing: -0.6)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              children: [
                SearchField(
                  controller: _search,
                  hint: 'Search settings',
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () => setState(() {
                    _search.clear();
                    _query = '';
                  }),
                ),
                if (!searching && account != null) ...[
                  const SizedBox(height: 18),
                  SettingsProfileCard(
                    label: account.label,
                    subtitle: Fmt.address(_primaryAddress(account)),
                    chains: _chainsOf(account).take(2).toList(),
                    onTap: () => _push(const ManageAccountsScreen()),
                  ),
                ],
                for (final group in groups) ...[
                  const SizedBox(height: 18),
                  SettingsSection(
                    children: [
                      for (final item in group)
                        SettingsRow(
                          icon: item.icon,
                          label: item.label,
                          accent: item.accent,
                          badge: item.badge,
                          onTap: item.onTap,
                        ),
                    ],
                  ),
                ],
                if (searching && groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text('No settings match “$_query”.',
                          style: NB.font(15, color: NB.text3)),
                    ),
                  ),
                if (!searching) ...[
                  const SizedBox(height: 22),
                  _ResetButton(onTap: () => confirmRemoveWallet(context, ref)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text('Nimbus · Version 1.0.0',
                        style: NB.font(12.5, color: NB.text3)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single settings entry. [matches] powers the search filter.
class _Item {
  const _Item({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final String? badge;

  bool matches(String query) =>
      query.isEmpty || label.toLowerCase().contains(query.toLowerCase());
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NB.red.withValues(alpha: 0.5), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text('Remove wallet from this device',
            style: NB.font(16, weight: FontWeight.w700, color: NB.red)),
      ),
    );
  }
}
