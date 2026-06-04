import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/presentation/widgets/recovery_phrase_grid.dart';
import '../widgets/nimbus_widgets.dart';

/// Shows the freshly generated 12-word recovery phrase. Blurred until the user
/// taps to reveal; the "I've saved it" gate stays disabled until then.
class RecoveryPhraseScreen extends StatefulWidget {
  const RecoveryPhraseScreen({
    super.key,
    required this.words,
    required this.onBack,
    required this.onContinue,
  });

  final List<String> words;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<RecoveryPhraseScreen> createState() => _RecoveryPhraseScreenState();
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
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
    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NbHeader(onBack: widget.onBack),
              Text('Your recovery phrase',
                  style: NB.font(27, weight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 10),
              Text(
                'Write these 12 words down in order and store them somewhere '
                'safe. Anyone with this phrase controls your wallet.',
                style: NB.font(14.5, color: NB.text2, height: 1.5),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RecoveryPhraseGrid(
                  words: widget.words,
                  onRevealed: () => setState(() => _revealed = true),
                ),
              ),
              const SizedBox(height: 14),
              _warning(),
              const SizedBox(height: 16),
              NbButton(
                label: "I've saved it",
                enabled: _revealed,
                onTap: widget.onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _warning() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _revealed ? _copy : null,
          child: Opacity(
            opacity: _revealed ? 1 : 0.4,
            child: Row(
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
      ],
    );
  }
}
