import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/chain_dots.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/account_avatar.dart';
import '../widgets/settings_scaffold.dart';
import 'account_detail_screen.dart';

/// Manage the wallet's accounts: switch the active one, rename, and add the next
/// account. Every account is derived from the same recovery phrase, so adding
/// one only bumps the derivation index — no new secret is created.
class ManageAccountsScreen extends ConsumerWidget {
  const ManageAccountsScreen({super.key});

  // Order chains by prominence for the compact dot stack.
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

  void _openDetail(BuildContext context, WalletAccount a) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => AccountDetailScreen(index: a.index),
      ));

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(walletSessionProvider.notifier).addAccount();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: NB.surface2,
            behavior: SnackBarBehavior.floating,
            content:
                Text('Couldn’t add account', style: NB.font(13, color: NB.text)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(walletSessionProvider);

    return SettingsScaffold(
      title: 'Accounts',
      intro: 'Each account is its own set of addresses — one per chain — all '
          'recoverable from your single recovery phrase.',
      children: [
        for (final a in session.accounts) ...[
          _AccountCard(
            account: a,
            active: a.index == session.activeAccountIndex,
            address: Fmt.address(_primaryAddress(a)),
            chains: _chainsOf(a),
            onSelect: () =>
                ref.read(walletSessionProvider.notifier).selectAccount(a.index),
            onEdit: () => _openDetail(context, a),
          ),
          const SizedBox(height: 12),
        ],
        _AddAccountButton(
          busy: session.isBusy,
          onTap: () => _add(context, ref),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.active,
    required this.address,
    required this.chains,
    required this.onSelect,
    required this.onEdit,
  });

  final WalletAccount account;
  final bool active;
  final String address;
  final List<Network> chains;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NB.surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? NB.orange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AccountAvatar(label: account.label, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NB.font(16, weight: FontWeight.w700)),
                      const SizedBox(height: 1),
                      Text(address, style: NB.font(13, color: NB.text2)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined, size: 18, color: NB.text3),
                  ),
                ),
                const SizedBox(width: 6),
                _SelectMark(active: active),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                ChainDots(networks: chains, size: 22, ring: NB.surface2),
                const SizedBox(width: 8),
                Text('${chains.length} chains',
                    style: NB.font(12.5, color: NB.text3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectMark extends StatelessWidget {
  const _SelectMark({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? NB.orange : Colors.transparent,
        border: active ? null : Border.all(color: NB.surface3, width: 2),
      ),
      child: active
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _AddAccountButton extends StatelessWidget {
  const _AddAccountButton({required this.busy, required this.onTap});
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: busy ? 0.5 : 1,
      child: GestureDetector(
        onTap: busy ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: NB.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NB.surface3),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('+',
                  style: TextStyle(
                      color: NB.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text('Add account', style: NB.font(15, weight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
