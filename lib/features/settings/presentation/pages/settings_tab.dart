import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/network_cluster.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/chain_dots.dart';
import '../widgets/settings_feedback.dart';
import '../widgets/settings_profile_card.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_section.dart';
import 'manage_accounts_screen.dart';
import 'network_screen.dart';
import 'security_screen.dart';

/// The Settings tab: a searchable, grouped list fusing a profile card, tinted
/// rows with live badges, a destructive reset, and a version footer. Rows with
/// real backing (accounts, security) drill in; the rest are honestly deferred.
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

  List<List<_Item>> _groups(WalletSessionState session, NetworkCluster cluster) {
    return [
      [
        _Item(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Manage Accounts',
          accent: NB.orange,
          badge: '${session.accounts.length}',
          onTap: () => _push(const ManageAccountsScreen()),
        ),
        _Item(
          icon: Icons.tune,
          label: 'Preferences',
          accent: NB.orange,
          onTap: () => showComingSoon(context),
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
          label: 'Active Networks',
          accent: NB.blue,
          badge: cluster.label,
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
    final cluster = ref.watch(networkClusterProvider);
    final account = session.activeAccount;
    final searching = _query.isNotEmpty;

    final groups = [
      for (final g in _groups(session, cluster))
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
                  _ResetButton(onTap: () => _reset(context)),
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

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ResetDialog(),
    );
    if (confirmed != true) return;
    // The gate watches vault status and routes back to onboarding once the
    // wallet is gone — no manual navigation needed.
    await ref.read(walletSessionProvider.notifier).deleteWallet();
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
        child: Text('Reset Wallet',
            style: NB.font(16, weight: FontWeight.w700, color: NB.red)),
      ),
    );
  }
}

class _ResetDialog extends StatelessWidget {
  const _ResetDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: NB.surface,
      title: Text('Reset wallet?',
          style: NB.font(18, weight: FontWeight.w800, color: NB.red)),
      content: Text(
        'This removes the wallet from this device. Your funds stay on-chain — '
        'you can restore everything with your recovery phrase. Without it, '
        'access is lost forever.',
        style: NB.font(14, color: NB.text2, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: NB.font(14, color: NB.text2)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Reset',
              style: NB.font(14, weight: FontWeight.w700, color: NB.red)),
        ),
      ],
    );
  }
}
