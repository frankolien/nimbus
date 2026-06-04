import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../wallet/data/crypto/mnemonic_service.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/passcode_pad.dart';
import '../widgets/passcode_step.dart';
import 'recovery_phrase_screen.dart';
import 'verify_phrase_screen.dart';
import 'wallet_ready_screen.dart';

enum _Step { reveal, verify, pinSet, pinConfirm, ready }

/// Orchestrates the "create a new wallet" sequence end to end. The generated
/// mnemonic lives only in this widget's memory until it's encrypted by the
/// vault; it is never logged.
class CreateWalletFlow extends ConsumerStatefulWidget {
  const CreateWalletFlow({
    super.key,
    required this.onExit,
    required this.onDone,
    this.debugMnemonic,
  });

  /// Called when the user backs out past the first step.
  final VoidCallback onExit;

  /// Called when the user taps "Open wallet" on the success screen.
  final VoidCallback onDone;

  /// Test-only: use this phrase instead of generating one, so a widget test
  /// can answer the verification quiz deterministically.
  @visibleForTesting
  final String? debugMnemonic;

  @override
  ConsumerState<CreateWalletFlow> createState() => _CreateWalletFlowState();
}

class _CreateWalletFlowState extends ConsumerState<CreateWalletFlow> {
  final _mnemonics = const MnemonicService();
  // Distinct keys: both pads are briefly mounted together during the
  // AnimatedSwitcher transition, so a shared key would collide.
  final _setPadKey = GlobalKey<PasscodePadState>();
  final _confirmPadKey = GlobalKey<PasscodePadState>();

  late final List<String> _words;
  _Step _step = _Step.reveal;
  String? _firstPin;
  String? _pinError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _words = (widget.debugMnemonic ?? _mnemonics.generate()).split(' ');
  }

  void _go(_Step s) => setState(() => _step = s);

  Future<void> _submitConfirmPin(String pin) async {
    if (pin != _firstPin) {
      setState(() => _pinError = "Codes didn't match — try again");
      _confirmPadKey.currentState?.shakeAndClear();
      return;
    }
    setState(() {
      _busy = true;
      _pinError = null;
    });
    try {
      await ref
          .read(walletSessionProvider.notifier)
          .createWallet(mnemonic: _words.join(' '), passcode: pin);
      if (mounted) _go(_Step.ready);
    } catch (_) {
      if (mounted) {
        setState(() => _pinError = 'Something went wrong. Try again.');
        _confirmPadKey.currentState?.shakeAndClear();
        _firstPin = null;
        _go(_Step.pinSet);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (_step) {
      _Step.reveal => RecoveryPhraseScreen(
          key: const ValueKey('reveal'),
          words: _words,
          onBack: widget.onExit,
          onContinue: () => _go(_Step.verify),
        ),
      _Step.verify => VerifyPhraseScreen(
          key: const ValueKey('verify'),
          words: _words,
          onBack: () => _go(_Step.reveal),
          onVerified: () => _go(_Step.pinSet),
        ),
      _Step.pinSet => PasscodeStep(
          key: const ValueKey('pinSet'),
          padKey: _setPadKey,
          title: 'Create a passcode',
          subtitle: 'Enter a 6-digit code to unlock Nimbus.',
          onBack: () => _go(_Step.verify),
          onCompleted: (pin) {
            _firstPin = pin;
            _go(_Step.pinConfirm);
          },
        ),
      _Step.pinConfirm => PasscodeStep(
          key: const ValueKey('pinConfirm'),
          padKey: _confirmPadKey,
          title: 'Confirm your passcode',
          subtitle: 'Re-enter your code to confirm.',
          errorText: _pinError,
          busy: _busy,
          onBack: () {
            _firstPin = null;
            _pinError = null;
            _go(_Step.pinSet);
          },
          onCompleted: _submitConfirmPin,
        ),
      _Step.ready => WalletReadyScreen(
          key: const ValueKey('ready'),
          account: ref.read(walletSessionProvider).accounts.first,
          onOpen: widget.onDone,
        ),
    };

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
