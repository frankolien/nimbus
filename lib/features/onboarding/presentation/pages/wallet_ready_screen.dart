import 'package:flutter/material.dart';
import 'package:nimbus/core/widgets/coin_logo.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/data/crypto/key_derivation_service.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../widgets/nimbus_widgets.dart';

/// Success screen after a wallet is created or imported — celebrates and shows
/// the real derived address for each chain.
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
                  Text('Welcome to self-custody, done right.',
                      style: NB.font(15, color: NB.text2)),
                  const SizedBox(height: 28),
                  _addressCard(),
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

  Widget _addressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NB.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NB.border),
      ),
      child: Column(
        children: [
          for (final family in KeyDerivationService.supportedFamilies)
            if (account.account(family) != null)
              _addressRow(
                Network.forFamily(family).first,
                _short(account.account(family)!.address),
              ),
        ],
      ),
    );
  }

  Widget _addressRow(Network network, String shortAddr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CoinLogo(network: network, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(network.displayName,
                style: NB.font(14.5, weight: FontWeight.w700)),
          ),
          Text(shortAddr, style: NB.font(13, color: NB.text2)),
        ],
      ),
    );
  }
}
