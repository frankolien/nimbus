import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../portfolio/presentation/providers/network_cluster_provider.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/network_cluster.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../data/evm_send_service.dart';
import '../../data/solana_send_service.dart';

/// Send native assets on an EVM chain or Solana. The send targets the active
/// [NetworkCluster], so the same screen works on Mainnet and Devnet/Testnet.
/// Bitcoin/Sui sending lands later.
class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  static const _sendable = [
    Network.ethereum,
    Network.polygon,
    Network.base,
    Network.solana,
  ];

  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _evm = EvmSendService();
  final _solana = SolanaSendService();

  Network _network = Network.solana;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text.trim());

  bool _isValidRecipient(String address) =>
      _network.family == ChainFamily.solana
          ? SolanaSendService.isValidAddress(address)
          : EvmSendService.isValidAddress(address);

  bool get _canSend =>
      !_sending &&
      _isValidRecipient(_toController.text.trim()) &&
      (_amount ?? 0) > 0;

  double _balanceFor(Network n) {
    final entries = ref.read(portfolioProvider).valueOrNull?.entries ?? [];
    for (final e in entries) {
      if (e.network == n) return e.amount ?? 0;
    }
    return 0;
  }

  Future<void> _send() async {
    final to = _toController.text.trim();
    final amount = _amountController.text.trim();
    if (!_canSend) return;

    if ((_amount ?? 0) > _balanceFor(_network)) {
      setState(() =>
          _error = 'Amount exceeds your ${_network.nativeSymbol} balance.');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final index = ref.read(walletSessionProvider).activeAccountIndex;
      final cluster = ref.read(networkClusterProvider);
      final vault = ref.read(walletVaultProvider);

      final String hash;
      if (_network.family == ChainFamily.solana) {
        final signer = vault.signingKey(ChainFamily.solana, index);
        hash = await _solana.sendNative(
          fromAddress: signer.address,
          privateKeyBytes: signer.privateKeyBytes,
          toAddress: to,
          amountSol: amount,
          cluster: cluster,
        );
      } else {
        final signer = vault.signingKey(ChainFamily.evm, index);
        hash = await _evm.sendNative(
          network: _network,
          privateKeyHex: signer.privateKeyHex,
          toAddress: to,
          amountEther: amount,
          cluster: cluster,
        );
      }

      if (mounted) {
        await _showResult(hash);
        ref.read(portfolioProvider.notifier).refresh();
        if (mounted) Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) setState(() => _error = _humanize(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _humanize(Object e) {
    if (e is SolanaRpcException) {
      final m = e.message.toLowerCase();
      if (m.contains('insufficient') || m.contains('debit')) {
        return 'Insufficient SOL for amount + fees.';
      }
      return e.message;
    }
    final s = e.toString();
    if (s.contains('insufficient funds')) {
      return 'Insufficient funds for amount + gas fees.';
    }
    return 'Could not send. Check the amount and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final cluster = ref.watch(networkClusterProvider);
    final balance = _balanceFor(_network);
    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NbHeader(onBack: () => Navigator.of(context).maybePop()),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Send',
                      style: NB.font(27,
                          weight: FontWeight.w800, letterSpacing: -0.6)),
                  const SizedBox(width: 12),
                  _ClusterChip(cluster: cluster),
                ],
              ),
              const SizedBox(height: 16),
              _networkPicker(),
              const SizedBox(height: 20),
              _label('To'),
              _field(_toController, 'Recipient address',
                  onChanged: (_) => setState(() => _error = null)),
              const SizedBox(height: 18),
              _label('Amount (${_network.nativeSymbol})'),
              _field(_amountController, '0.0',
                  keyboard:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() => _error = null)),
              const SizedBox(height: 8),
              Text(
                  'Balance: ${balance.toStringAsFixed(6)} ${_network.nativeSymbol}',
                  style: NB.font(12.5, color: NB.text2)),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: NB.font(13, color: NB.red)),
              ],
              const Spacer(),
              NbButton(
                label: _sending ? 'Sending…' : 'Review & send',
                enabled: _canSend,
                onTap: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child:
            Text(t, style: NB.font(13, weight: FontWeight.w700, color: NB.text2)),
      );

  Widget _field(
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NB.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NB.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        onChanged: onChanged,
        autocorrect: false,
        enableSuggestions: false,
        style: NB.font(15, color: NB.text),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: NB.font(15, color: NB.text3),
        ),
      ),
    );
  }

  Widget _networkPicker() {
    return Row(
      children: [
        for (final n in _sendable) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _network = n;
                _error = null;
              }),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: n == _network
                      ? NB.orange.withValues(alpha: 0.14)
                      : NB.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: n == _network ? NB.orange : NB.border,
                      width: n == _network ? 1.4 : 1),
                ),
                child: Text(n.nativeSymbol,
                    style: NB.font(13,
                        weight: FontWeight.w700,
                        color: n == _network ? NB.orange : NB.text2)),
              ),
            ),
          ),
          if (n != _sendable.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  String _explorerUrl(String hash, NetworkCluster cluster) {
    if (_network.family == ChainFamily.solana) {
      final q = cluster.isMainnet ? '' : '?cluster=${cluster.id}';
      return 'https://solscan.io/tx/$hash$q';
    }
    return '${_network.explorerBaseUrl}/tx/$hash';
  }

  Future<void> _showResult(String hash) async {
    final cluster = ref.read(networkClusterProvider);
    final url = _explorerUrl(hash, cluster);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NB.surface,
        title:
            Text('Transaction sent', style: NB.font(18, weight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Your ${_network.displayName} transfer was broadcast on '
                '${cluster.label}.',
                style: NB.font(14, color: NB.text2, height: 1.5)),
            const SizedBox(height: 12),
            SelectableText(hash, style: NB.font(12, color: NB.text3)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: hash)),
            child: Text('Copy', style: NB.font(14, color: NB.text2)),
          ),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication),
            child: Text('View',
                style: NB.font(14, weight: FontWeight.w700, color: NB.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Done', style: NB.font(14, color: NB.text)),
          ),
        ],
      ),
    );
  }
}

/// Small chip echoing the active cluster so it's clear which environment a send
/// will hit. Orange off-mainnet, muted on mainnet.
class _ClusterChip extends StatelessWidget {
  const _ClusterChip({required this.cluster});
  final NetworkCluster cluster;

  @override
  Widget build(BuildContext context) {
    final accent = cluster.isMainnet ? NB.text3 : NB.orangeHi;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(cluster.label,
          style: NB.font(11.5, weight: FontWeight.w700, color: accent)),
    );
  }
}
