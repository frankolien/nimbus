import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/data/crypto/mnemonic_service.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../widgets/nimbus_widgets.dart';
import '../widgets/passcode_pad.dart';
import '../widgets/passcode_step.dart';
import 'wallet_ready_screen.dart';

enum _Step { enter, pinSet, pinConfirm, ready }

/// "I already have a wallet" — paste a 12/24-word phrase, validate it, then set
/// a passcode and derive the accounts.
class ImportWalletFlow extends ConsumerStatefulWidget {
  const ImportWalletFlow({super.key, required this.onExit, required this.onDone});

  final VoidCallback onExit;
  final VoidCallback onDone;

  @override
  ConsumerState<ImportWalletFlow> createState() => _ImportWalletFlowState();
}

class _ImportWalletFlowState extends ConsumerState<ImportWalletFlow> {
  final _mnemonics = const MnemonicService();
  // Distinct keys: both pads are briefly mounted together during the
  // AnimatedSwitcher transition, so a shared key would collide.
  final _setPadKey = GlobalKey<PasscodePadState>();
  final _confirmPadKey = GlobalKey<PasscodePadState>();

  _Step _step = _Step.enter;
  String _phrase = '';
  String? _firstPin;
  String? _pinError;
  bool _busy = false;

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
          .importWallet(mnemonic: _phrase, passcode: pin);
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
      _Step.enter => _EnterPhrase(
          key: const ValueKey('enter'),
          mnemonics: _mnemonics,
          onBack: widget.onExit,
          onValid: (phrase) {
            _phrase = phrase;
            _go(_Step.pinSet);
          },
        ),
      _Step.pinSet => PasscodeStep(
          key: const ValueKey('pinSet'),
          padKey: _setPadKey,
          title: 'Create a passcode',
          subtitle: 'Enter a 6-digit code to unlock Nimbus.',
          onBack: () => _go(_Step.enter),
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

class _EnterPhrase extends StatefulWidget {
  const _EnterPhrase({
    super.key,
    required this.mnemonics,
    required this.onBack,
    required this.onValid,
  });

  final MnemonicService mnemonics;
  final VoidCallback onBack;
  final ValueChanged<String> onValid;

  @override
  State<_EnterPhrase> createState() => _EnterPhraseState();
}

class _EnterPhraseState extends State<_EnterPhrase> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _wordCount {
    final t = _controller.text.trim();
    return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
  }

  void _submit() {
    final phrase = widget.mnemonics.normalize(_controller.text);
    try {
      widget.mnemonics.validateOrThrow(phrase);
      widget.onValid(phrase);
    } on MnemonicValidationException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _wordCount;
    final lengthOk = count == 12 || count == 24;
    return Scaffold(
      backgroundColor: NB.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NbHeader(onBack: widget.onBack),
              Text('Import a wallet',
                  style: NB.font(27, weight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 10),
              Text(
                'Enter your 12 or 24-word recovery phrase. It’s encrypted on this '
                'device and never leaves your phone.',
                style: NB.font(14.5, color: NB.text2, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: NB.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _error != null ? NB.red : NB.border),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() => _error = null),
                  maxLines: 4,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  style: NB.font(15, color: NB.text, height: 1.6),
                  decoration: InputDecoration.collapsed(
                    hintText: 'recovery phrase…',
                    hintStyle: NB.font(15, color: NB.text3),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _error ?? 'Separate words with spaces',
                    style: NB.font(12,
                        color: _error != null ? NB.red : NB.text3),
                  ),
                  Text('$count word${count == 1 ? '' : 's'}',
                      style: NB.font(12,
                          weight: FontWeight.w700,
                          color: lengthOk ? NB.green : NB.text2)),
                ],
              ),
              const Spacer(),
              NbButton(
                label: 'Import wallet',
                enabled: lengthOk,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
