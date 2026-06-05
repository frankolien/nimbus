import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/chain_dots.dart';
import '../../../market/presentation/pages/token_detail_screen.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../settings/presentation/pages/account_detail_screen.dart';
import '../../../transfer/presentation/pages/receive_screen.dart';
import '../../../transfer/presentation/pages/send_screen.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../providers/balance_visibility_provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/asset_list.dart';
import '../widgets/devnet_bar.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/portfolio_total.dart';
import '../widgets/wallet_actions.dart';

/// The realtime multi-chain wallet tab. Composes presentational widgets and
/// wires them to the session + portfolio providers; holds no layout details of
/// its own beyond ordering.
class WalletTab extends ConsumerWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(walletSessionProvider);
    final portfolio = ref.watch(portfolioProvider).valueOrNull;
    final hidden = ref.watch(balanceHiddenProvider);
    final account = session.activeAccount;
    final name = account?.label ?? 'Wallet';
    final chains = <Network>[
      for (final family in const [
        ChainFamily.solana,
        ChainFamily.evm,
        ChainFamily.bitcoin,
        ChainFamily.sui,
      ])
        if (account?.account(family) != null) ChainDots.representative(family),
    ];

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: NB.orange,
        backgroundColor: NB.surface,
        onRefresh: () => ref.read(portfolioProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            HomeTopBar(
              accountName: name,
              chains: chains,
              balanceHidden: hidden,
              onTapAccount: () => _push(
                context,
                AccountDetailScreen(index: session.activeAccountIndex),
              ),
              onToggleBalance: () =>
                  ref.read(balanceHiddenProvider.notifier).toggle(),
            ),
            //const DevnetBar(),
            const SizedBox(height: 17),
            PortfolioTotalHeader(
              totalUsd: portfolio?.totalUsd,
              change: portfolio?.delta24h,
              hidden: hidden,
            ),
            const SizedBox(height: 19),
            WalletActions(actions: _actions(context)),
            const SizedBox(height: 22),
            const Divider(color: NB.border, height: 1),
            const SizedBox(height: 18),
            Text('My assets', style: NB.font(17, weight: FontWeight.w800)),
            const SizedBox(height: 12),
            AssetList(
              entries: portfolio?.entries,
              onTap: (network) => _openToken(context, network),
              hidden: hidden,
            ),
            const SizedBox(height: 18),
            Center(
              child: NbButton(
                label: 'Manage assets',
                variant: NbBtnVariant.outline,
                leading: const Icon(Icons.add, size: 18, color: NB.text),
                onTap: () => _soon(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<WalletAction> _actions(BuildContext context) => [
        WalletAction(icon: Icons.add, label: 'Buy', onTap: () => _soon(context)),
        WalletAction(
            icon: Icons.arrow_upward,
            label: 'Send',
            onTap: () => _push(context, const SendScreen())),
        WalletAction(
            icon: Icons.swap_horiz, label: 'Swap', onTap: () => _soon(context)),
        WalletAction(
            icon: Icons.arrow_downward,
            label: 'Receive',
            onTap: () => _push(context, const ReceiveScreen())),
      ];

  void _openToken(BuildContext context, Network network) =>
      _push(context, TokenDetailScreen(network: network));

  void _push(BuildContext context, Widget page) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => page));

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NB.surface2,
        content: Text('Coming soon', style: NB.font(13, color: NB.text)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
