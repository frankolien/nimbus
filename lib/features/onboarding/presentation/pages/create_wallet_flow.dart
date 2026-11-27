import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/nimbus_widgets.dart';
import '../xend_error_text.dart';
import 'wallet_ready_screen.dart';

/// Creates a wallet in one step. The key is made in the Secure Enclave and its
/// seed backed up to iCloud Keychain; no phrase is shown here. It can be
/// exported later from Settings.
class CreateWalletFlow extends ConsumerStatefulWidget {
  const CreateWalletFlow({super.key, required this.onExit, required this.onDone});

  /// Called when the user backs out.
  final VoidCallback onExit;

  /// Called when the user taps "Open wallet" on the success screen.
  final VoidCallback onDone;

  @override
  ConsumerState<CreateWalletFlow> createState() => _CreateWalletFlowState();
}

class _CreateWalletFlowState extends ConsumerState<CreateWalletFlow> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Start after the first frame so the provider isn't modified during build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _create());
  }

  Future<void> _create() async {
    setState(() => _error = null);
    try {
      await ref.read(walletSessionProvider.notifier).createWallet();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('createWallet failed: $e');
      if (mounted) setState(() => _error = xendErrorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(walletSessionProvider).activeAccount;
    final Widget child = _ready && account != null
        ? WalletReadyScreen(
            key: const ValueKey('ready'),
            account: account,
            onOpen: widget.onDone,
          )
        : _Creating(
            key: const ValueKey('creating'),
            error: _error,
            onBack: widget.onExit,
            onRetry: _create,
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (c, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.08, 0), end: Offset.zero)
              .animate(anim),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

/// Progress while the key is created, or the error with a retry.
class _Creating extends StatelessWidget {
  const _Creating({
    super.key,
    required this.error,
    required this.onBack,
    required this.onRetry,
  });

  final String? error;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failed = error != null;
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
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
              child: Column(
                children: [
                  NbHeader(onBack: onBack, showHelp: false),
                  const Spacer(),
                  const NimbusLogo(size: 72),
                  const SizedBox(height: 28),
                  Text(
                    failed ? 'Couldn’t create your wallet' : 'Creating your wallet',
                    textAlign: TextAlign.center,
                    style: NB.font(26, weight: FontWeight.w800, letterSpacing: -0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error ??
                        'Your key is made on this device and backed up to your '
                            'iCloud Keychain.',
                    textAlign: TextAlign.center,
                    style: NB.font(14.5,
                        color: failed ? NB.red : NB.text2, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  if (!failed)
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: NB.orange),
                    ),
                  const Spacer(),
                  if (failed) NbButton(label: 'Try again', onTap: onRetry),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
