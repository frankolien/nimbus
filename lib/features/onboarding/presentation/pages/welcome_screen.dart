import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../widgets/nimbus_widgets.dart';

/// First screen — brand, value prop, and the two entry points.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onCreate, required this.onImport});

  final VoidCallback onCreate;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NB.bg,
      body: Stack(
        children: [
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(child: AmbientGlow()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  const NimbusLogo(size: 70),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Wordmark(size: 26),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: NB.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text('MPC',
                            style: NB.font(11,
                                weight: FontWeight.w700,
                                color: NB.orange,
                                letterSpacing: 1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'A crypto wallet\nreimagined for\nevery chain',
                    style: NB.font(34,
                        weight: FontWeight.w800,
                        color: NB.text,
                        height: 1.12,
                        letterSpacing: -1),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Self-custody across Solana, Ethereum, Bitcoin and Sui — '
                    'one recovery phrase, keys that never leave your device.',
                    style: NB.font(15.5, color: NB.text2, height: 1.5),
                  ),
                  const Spacer(flex: 3),
                  NbButton(label: 'Create a new wallet', onTap: onCreate),
                  const SizedBox(height: 12),
                  NbButton(
                    label: 'I already have a wallet',
                    variant: NbBtnVariant.outline,
                    onTap: onImport,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text.rich(
                      const TextSpan(
                        text: 'By continuing you agree to Nimbus’s ',
                        children: [
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: NB.text2)),
                          TextSpan(text: ' & '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: NB.text2)),
                          TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: NB.font(11.5, color: NB.text3, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
