import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../onboarding/presentation/widgets/passcode_pad.dart';
import '../../../onboarding/presentation/widgets/passcode_step.dart';
import '../../../wallet/data/crypto/seed_cipher.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../../wallet/presentation/widgets/recovery_phrase_grid.dart';
import '../widgets/settings_scaffold.dart';

/// Reveals the recovery phrase from Settings, gated by a passcode re-check.
///
/// Two stages: enter the passcode (verified by decrypting the stored seed), then
/// the 12 words behind a tap-to-reveal blur. The decrypted phrase lives only in
/// transient state for this screen and is dropped when it closes — it is never
/// stored in a provider or logged.
class RevealPhraseScreen extends ConsumerStatefulWidget {
  const RevealPhraseScreen({super.key});

  @override
  ConsumerState<RevealPhraseScreen> createState() => _RevealPhraseScreenState();
}

class _RevealPhraseScreenState extends ConsumerState<RevealPhraseScreen> {
  final _padKey = GlobalKey<PasscodePadState>();
  List<String>? _words;
  String? _error;
  bool _busy = false;

  Future<void> _verify(String passcode) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final phrase =
          await ref.read(walletVaultProvider).revealRecoveryPhrase(passcode);
      if (!mounted) return;
      setState(() => _words = phrase.split(RegExp(r'\s+')));
    } on InvalidPasscodeException {
      _padKey.currentState?.shakeAndClear();
      if (mounted) setState(() => _error = 'Incorrect passcode');
    } catch (e) {
      debugPrint('revealRecoveryPhrase failed: $e');
      _padKey.currentState?.shakeAndClear();
      if (mounted) setState(() => _error = 'Couldn’t read your wallet');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _words;
    if (words == null) {
      return PasscodeStep(
        padKey: _padKey,
        title: 'Enter your passcode',
        subtitle: 'Confirm it’s you to reveal your recovery phrase',
        errorText: _error,
        busy: _busy,
        onBack: () => Navigator.of(context).maybePop(),
        onCompleted: _verify,
      );
    }
    return _PhraseStage(words: words);
  }
}

class _PhraseStage extends StatefulWidget {
  const _PhraseStage({required this.words});
  final List<String> words;

  @override
  State<_PhraseStage> createState() => _PhraseStageState();
}

class _PhraseStageState extends State<_PhraseStage> {
  bool _revealed = false;
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.words.join(' ')));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Recovery phrase',
      children: [
        _warningBanner(),
        const SizedBox(height: 16),
        RecoveryPhraseGrid(
          words: widget.words,
          shrinkWrap: true,
          onRevealed: () => setState(() => _revealed = true),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _revealed ? _copy : null,
            child: Opacity(
              opacity: _revealed ? 1 : 0.4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_copied ? Icons.check : Icons.copy_rounded,
                      size: 16, color: _copied ? NB.green : NB.text2),
                  const SizedBox(width: 6),
                  Text(_copied ? 'Copied' : 'Copy to clipboard',
                      style: NB.font(13,
                          weight: FontWeight.w700,
                          color: _copied ? NB.green : NB.text2)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        NbButton(
          label: 'Done',
          variant: NbBtnVariant.ghost,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  Widget _warningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NB.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NB.red.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 20, color: NB.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Never share these words. Anyone with your recovery phrase has '
              'full control of your wallet.',
              style: NB.font(13, color: NB.text2, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
