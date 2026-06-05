import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/coin_logo.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/transfer_header.dart';

/// Per-asset receive screen: the address for one chain as a big QR + copyable
/// text, with a network-scoped warning so funds aren't sent on the wrong chain.
class ReceiveDetailScreen extends ConsumerWidget {
  const ReceiveDetailScreen({super.key, required this.network});

  final Network network;

  String get _warning => network.family == ChainFamily.evm
      ? 'Only send Ethereum or EVM network tokens (Polygon, Base…) to this '
          'address.'
      : 'Only send ${network.displayName} network tokens to this address.';

  void _copy(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    _toast(context, 'Address copied');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: NB.surface2,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      content: Text(message, style: NB.font(13, color: NB.text)),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(walletSessionProvider).activeAccount;
    final address = account?.account(network.family)?.address ?? '';

    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Column(
          children: [
            TransferHeader(title: network.displayName),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    CoinLogo(network: network, size: 72),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: NB.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: NB.border),
                      ),
                      child: Column(
                        children: [
                          Text(_warning,
                              textAlign: TextAlign.center,
                              style: NB.font(13.5,
                                  weight: FontWeight.w600,
                                  color: NB.text,
                                  height: 1.45)),
                          const SizedBox(height: 14),
                          const Divider(color: NB.border, height: 1),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(address,
                                    style: NB.font(13,
                                        weight: FontWeight.w600, height: 1.4)),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _copy(context, address),
                                behavior: HitTestBehavior.opaque,
                                child: const Icon(Icons.copy_rounded,
                                    size: 20, color: NB.text2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: QrImageView(
                              data: address,
                              version: QrVersions.auto,
                              size: 216,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _action(
                          icon: Icons.south_west,
                          label: 'Request',
                          onTap: () => _toast(context, 'Coming soon'),
                        ),
                        const SizedBox(width: 44),
                        _action(
                          icon: Icons.ios_share,
                          label: 'Share',
                          onTap: () => _copy(context, address),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                const BoxDecoration(color: NB.surface2, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: NB.text),
          ),
          const SizedBox(height: 7),
          Text(label, style: NB.font(12.5, color: NB.text2)),
        ],
      ),
    );
  }
}
