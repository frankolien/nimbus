import 'package:flutter/material.dart';
import 'package:nimbus/core/widgets/coin_logo.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/domain/entities/chain_family.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../widgets/nimbus_widgets.dart';

/// Success screen after a wallet is created or imported. Shows the Solana
/// address and where the backup lives.
class WalletReadyScreen extends StatelessWidget {
  const WalletReadyScreen({
    super.key,
    required this.account,
    required this.onOpen,
  });

  final WalletAccount account;
  final VoidCallback onOpen;

  static String _short(String addr) =>
      addr.length <= 13 ? addr : '${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}';

  @override
  Widget build(BuildContext context) {
    final address = account.account(ChainFamily.solana)?.address;
    return Scaffold(
      backgroundColor: NB.bg,
      body: Stack(
        children: [
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: AmbientGlow(color: NB.green, size: 380, opacity: 0.22),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF3BE68C), Color(0xFF1FA862)],
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x662FD37E),
                            blurRadius: 50,
                            offset: Offset(0, 16)),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 26),
                  Text('Your wallet is ready',
                      style: NB.font(30, weight: FontWeight.w800, letterSpacing: -0.8)),
                  const SizedBox(height: 10),
                  Text('Face ID approves every transaction.',
                      style: NB.font(15, color: NB.text2)),
                  const SizedBox(height: 28),
                  if (address != null) _addressCard(address),
                  const SizedBox(height: 12),
                  _backupNote(),
                  const Spacer(),
                  NbButton(label: 'Open wallet', onTap: onOpen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(String address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: NB.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NB.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            const CoinLogo(network: Network.solana, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Text(Network.solana.displayName,
                  style: NB.font(14.5, weight: FontWeight.w700)),
            ),
            Text(_short(address), style: NB.font(13, color: NB.text2)),
          ],
        ),
      ),
    );
  }

  Widget _backupNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NB.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NB.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_done_outlined, size: 20, color: NB.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Backed up to your iCloud Keychain. You can also export your '
              'recovery phrase anytime in Settings.',
              style: NB.font(13, color: NB.text2, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
