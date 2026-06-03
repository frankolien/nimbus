import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../wallet/data/crypto/mnemonic_service.dart';
import '../widgets/nimbus_widgets.dart';

/// Confirms the user actually backed up the phrase by asking them to pick the
/// correct word for three random positions.
class VerifyPhraseScreen extends StatefulWidget {
  const VerifyPhraseScreen({
    super.key,
    required this.words,
    required this.onBack,
    required this.onVerified,
    this.mnemonics = const MnemonicService(),
  });

  final List<String> words;
  final VoidCallback onBack;
  final VoidCallback onVerified;
  final MnemonicService mnemonics;

  @override
  State<VerifyPhraseScreen> createState() => _VerifyPhraseScreenState();
}

class _Challenge {
  _Challenge(this.position, this.options);
  final int position; // 0-based index into words
  final List<String> options;
}

class _VerifyPhraseScreenState extends State<VerifyPhraseScreen> {
  late final List<_Challenge> _challenges;
  int _current = 0;
  String? _wrongPick;

  @override
  void initState() {
    super.initState();
    _challenges = _buildChallenges();
  }

  List<_Challenge> _buildChallenges() {
    // Deterministic per-session positions; fixed seed keeps it stable across
    // rebuilds within this screen instance.
    final rng = Random(widget.words.join().hashCode);
    final positions = <int>{};
    while (positions.length < 3) {
      positions.add(rng.nextInt(widget.words.length));
    }
    final sorted = positions.toList()..sort();
    return [
      for (var i = 0; i < sorted.length; i++)
        _Challenge(
          sorted[i],
          () {
            final correct = widget.words[sorted[i]];
            final opts = <String>{correct};
            opts.addAll(widget.mnemonics
                .decoys({correct}, 3, seed: sorted[i] * 131 + i));
            final list = opts.toList()..shuffle(Random(sorted[i] + 7));
            return list;
          }(),
        ),
    ];
  }

  void _pick(String word) {
    final challenge = _challenges[_current];
    final correct = widget.words[challenge.position];
    if (word != correct) {
      setState(() => _wrongPick = word);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrongPick = null);
      });
      return;
    }
    if (_current == _challenges.length - 1) {
      widget.onVerified();
    } else {
      setState(() => _current++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_current];
    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NbHeader(onBack: widget.onBack),
              Row(
                children: List.generate(_challenges.length, (i) {
                  final done = i < _current;
                  final active = i == _current;
                  return Container(
                    margin: const EdgeInsets.only(right: 7),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: done || active
                          ? NB.orange
                          : Colors.white.withValues(alpha: 0.18),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text('Confirm your phrase',
                  style: NB.font(27, weight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 10),
              Text(
                'Select the correct word for each position to confirm you saved '
                'your recovery phrase.',
                style: NB.font(14.5, color: NB.text2, height: 1.5),
              ),
              const Spacer(),
              Center(
                child: Text('What is word',
                    style: NB.font(15, color: NB.text2)),
              ),
              Center(
                child: Text('#${challenge.position + 1}',
                    style: NB.font(48, weight: FontWeight.w800, color: NB.orange)),
              ),
              const SizedBox(height: 28),
              ...challenge.options.map(_optionTile),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(String word) {
    final isWrong = _wrongPick == word;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _pick(word),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: NB.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isWrong ? NB.red : NB.border,
              width: isWrong ? 1.5 : 1,
            ),
          ),
          child: Text(word,
              style: NB.font(16,
                  weight: FontWeight.w700,
                  color: isWrong ? NB.red : NB.text)),
        ),
      ),
    );
  }
}
