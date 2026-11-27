import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xend/xend.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../onboarding/presentation/xend_error_text.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../../wallet/presentation/widgets/recovery_phrase_grid.dart';
import '../widgets/settings_scaffold.dart';

/// Exports the recovery phrase behind Face ID.
///
/// The phrase lives only in this screen's state and is dropped when it closes.
/// It is never stored in a provider or logged.
class RevealPhraseScreen extends ConsumerStatefulWidget {
  const RevealPhraseScreen({super.key});

  @override
  ConsumerState<RevealPhraseScreen> createState() => _RevealPhraseScreenState();
}

class _RevealPhraseScreenState extends ConsumerState<RevealPhraseScreen> {
  List<String>? _words;
  String? _error;
  bool _busy = false;

  Future<void> _reveal() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final phrase =
          await ref.read(walletSessionProvider.notifier).revealRecoveryPhrase();
      if (!mounted) return;
      setState(() => _words = phrase.trim().split(RegExp(r'\s+')));
    } on UserCancelledAuth {
      // The user closed the prompt. Let them try again.
      if (mounted) setState(() => _error = 'Face ID was cancelled. Try again when ready.');
    } catch (e) {
      debugPrint('revealRecoveryPhrase failed: ${e.runtimeType}');
      if (mounted) setState(() => _error = xendErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _words;
    if (words != null) return _PhraseStage(words: words);
    return SettingsScaffold(
      title: 'Recovery phrase',
      intro: 'Your wallet is already backed up to your iCloud Keychain. Write '
          'these words down as a second backup, or to move the wallet to a '
          'device outside your Apple account.',
      children: [
        const _WarningBanner(),
        const SizedBox(height: 22),
        NbButton(
          label: _busy ? 'Waiting for Face ID…' : 'Reveal with Face ID',
          leading: const Icon(Icons.face_outlined, size: 20, color: Colors.white),
          enabled: !_busy,
          onTap: _reveal,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(_error!,
                textAlign: TextAlign.center,
                style: NB.font(13, color: NB.text2)),
          ),
        ],
      ],
    );
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
        const _WarningBanner(),
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
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) {
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
