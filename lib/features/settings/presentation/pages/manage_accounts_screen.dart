import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/chain_dots.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/account_avatar.dart';
import '../widgets/settings_scaffold.dart';
import 'account_detail_screen.dart';

/// The wallet's account. There is one per device; tap it to rename or copy
/// the address.
class ManageAccountsScreen extends ConsumerWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(walletSessionProvider).activeAccount;

    return SettingsScaffold(
      title: 'Account',
      intro: 'Nimbus holds one Solana wallet on this device, backed up to your '
          'iCloud Keychain.',
      children: [
        if (account != null)
          _AccountCard(
            account: account,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => AccountDetailScreen(index: account.index),
            )),
          ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap});

  final WalletAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final address = account.account(ChainFamily.solana)?.address ?? '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NB.surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: NB.orange, width: 1.5),
        ),
        child: Row(
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
                  Text(Fmt.address(address),
                      style: NB.font(13, color: NB.text2)),
                ],
              ),
            ),
            ChainDots(
              networks: [ChainDots.representative(ChainFamily.solana)],
              size: 22,
              ring: NB.surface2,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 18, color: NB.text3),
          ],
        ),
      ),
    );
  }
}
