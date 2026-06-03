import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/nimbus_theme.dart';
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
              Expanded(child: _phraseGrid()),
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

  Widget _phraseGrid() {
    final grid = GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.words.length,
      itemBuilder: (context, i) => _wordPill(i + 1, widget.words[i]),
    );

    return Container(
      decoration: BoxDecoration(
        color: NB.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NB.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          grid,
          if (!_revealed)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _revealed = true),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: NB.surface.withValues(alpha: 0.4),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility_outlined,
                              color: NB.text, size: 28),
                          const SizedBox(height: 10),
                          Text('Tap to reveal',
                              style: NB.font(15, weight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Make sure no one is watching',
                              style: NB.font(12.5, color: NB.text2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _wordPill(int n, String word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: NB.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('$n', style: NB.font(13, color: NB.text3)),
          ),
          Expanded(
            child: Text(word,
                style: NB.font(14.5, weight: FontWeight.w600, color: NB.text)),
          ),
        ],
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
