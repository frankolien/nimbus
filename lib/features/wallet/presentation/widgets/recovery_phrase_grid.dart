import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// The recovery phrase rendered as a numbered two-column grid inside a bordered
/// card, blurred behind a "Tap to reveal" overlay until the user opts in.
///
/// Shared by onboarding backup and the in-app reveal-from-Settings flow so the
/// phrase is presented identically wherever it appears. Wrap in [Expanded] to
/// fill available height (the grid never scrolls).
class RecoveryPhraseGrid extends StatefulWidget {
  const RecoveryPhraseGrid({
    super.key,
    required this.words,
    this.onRevealed,
    this.shrinkWrap = false,
  });

  final List<String> words;

  /// Fired once when the user reveals the phrase, so the parent can enable a
  /// "saved it" / copy affordance.
  final VoidCallback? onRevealed;

  /// When true the card sizes to its content (for use inside a scroll view);
  /// when false it fills its parent (wrap in [Expanded]).
  final bool shrinkWrap;

  @override
  State<RecoveryPhraseGrid> createState() => _RecoveryPhraseGridState();
}

class _RecoveryPhraseGridState extends State<RecoveryPhraseGrid> {
  bool _revealed = false;

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    widget.onRevealed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NB.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NB.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: widget.shrinkWrap ? StackFit.loose : StackFit.expand,
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: widget.shrinkWrap,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.words.length,
            itemBuilder: (context, i) => _wordPill(i + 1, widget.words[i]),
          ),
          if (!_revealed)
            Positioned.fill(
              child: GestureDetector(
                onTap: _reveal,
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
          SizedBox(width: 22, child: Text('$n', style: NB.font(13, color: NB.text3))),
          Expanded(
            child: Text(word,
                style: NB.font(14.5, weight: FontWeight.w600, color: NB.text)),
          ),
        ],
      ),
    );
  }
}
