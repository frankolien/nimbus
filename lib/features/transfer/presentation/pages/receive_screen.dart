import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';

/// Receive funds: pick a network, show the matching address as a QR + copyable
/// text. EVM networks share one address (derived once for the family).
class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  Network _network = Network.solana;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(walletSessionProvider).activeAccount;
    final address = account?.account(_network.family)?.address ?? '';

    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NbHeader(onBack: () => Navigator.of(context).maybePop()),
              Text('Receive',
                  style: NB.font(27, weight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 16),
              _networkPicker(),
              const SizedBox(height: 24),
              _qrCard(address),
              const SizedBox(height: 20),
              _warning(),
              const Spacer(),
              NbButton(
                label: _copied ? 'Copied' : 'Copy address',
                leading: Icon(_copied ? Icons.check : Icons.copy_rounded,
                    size: 18, color: Colors.white),
                onTap: () => _copy(address),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _networkPicker() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: Network.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final n = Network.values[i];
          final selected = n == _network;
          return GestureDetector(
            onTap: () => setState(() {
              _network = n;
              _copied = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? NB.orange.withValues(alpha: 0.14) : NB.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected ? NB.orange : NB.border,
                    width: selected ? 1.4 : 1),
              ),
              child: Text(n.displayName,
                  style: NB.font(13.5,
                      weight: FontWeight.w700,
                      color: selected ? NB.orange : NB.text2)),
            ),
          ); 
        },
      ),
    );
  }

  Widget _qrCard(String address) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: NB.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NB.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: address,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text('${_network.displayName} address',
              style: NB.font(12.5, color: NB.text2)),
          const SizedBox(height: 6),
          SelectableText(
            address,
            textAlign: TextAlign.center,
            style: NB.font(13.5, weight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _warning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NB.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: NB.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only send ${_network.displayName} network assets to this address. '
              'Sending other assets may lose them.',
              style: NB.font(12.5, color: NB.text2, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(String address) {
    Clipboard.setData(ClipboardData(text: address));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }
}
