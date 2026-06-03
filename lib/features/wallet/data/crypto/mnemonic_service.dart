import 'dart:math';

import 'package:blockchain_utils/blockchain_utils.dart';

/// Generates, validates, and normalizes BIP39 recovery phrases.
///
/// This is the single source of truth for mnemonics in the app. It wraps
/// `blockchain_utils` so the rest of the codebase never touches the crypto
/// library directly and we can swap implementations without churn.
class MnemonicService {
  const MnemonicService();

  /// Generate a fresh English BIP39 mnemonic.
  ///
  /// [wordCount] must be 12 (default) or 24. 12 words = 128-bit entropy, the
  /// Phantom default; 24 words = 256-bit.
  String generate({int wordCount = 12}) {
    final words = switch (wordCount) {
      12 => Bip39WordsNum.wordsNum12,
      24 => Bip39WordsNum.wordsNum24,
      _ => throw ArgumentError('wordCount must be 12 or 24, got $wordCount'),
    };
    return Bip39MnemonicGenerator().fromWordsNumber(words).toStr();
  }

  /// True if [phrase] is a structurally valid BIP39 mnemonic (correct word
  /// count, all words in the wordlist, valid checksum).
  bool isValid(String phrase) {
    try {
      return Bip39MnemonicValidator().isValid(normalize(phrase));
    } catch (_) {
      return false;
    }
  }

  /// Validate and throw a descriptive [MnemonicValidationException] on failure.
  void validateOrThrow(String phrase) {
    final normalized = normalize(phrase);
    final count = normalized.isEmpty ? 0 : normalized.split(' ').length;
    if (count != 12 && count != 15 && count != 18 && count != 21 && count != 24) {
      throw const MnemonicValidationException(
        'Recovery phrase must be 12 or 24 words.',
      );
    }
    if (!isValid(normalized)) {
      throw const MnemonicValidationException(
        'This recovery phrase is invalid. Check the words and their order.',
      );
    }
  }

  /// Trim, lowercase, and collapse internal whitespace to single spaces.
  /// BIP39 English words are lowercase; normalizing avoids spurious mismatches
  /// from copy/paste artifacts.
  String normalize(String phrase) =>
      phrase.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// [count] random wordlist words excluding everything in [exclude], for use
  /// as decoy options in a backup-verification quiz.
  List<String> decoys(Set<String> exclude, int count, {required int seed}) {
    final rng = Random(seed);
    final picked = <String>{};
    var guard = 0;
    while (picked.length < count && guard++ < 10000) {
      final w = _englishWords[rng.nextInt(_englishWords.length)];
      if (!exclude.contains(w)) picked.add(w);
    }
    return picked.toList();
  }

  /// The list of valid words for a given prefix, for autocomplete during import.
  List<String> suggestions(String prefix, {int limit = 5}) {
    final p = prefix.trim().toLowerCase();
    if (p.isEmpty) return const [];
    return _englishWords
        .where((w) => w.startsWith(p))
        .take(limit)
        .toList();
  }
}

/// The 2048-word English BIP39 wordlist, materialized once and reused.
final List<String> _englishWords = () {
  final list = Bip39WordsListGetter().getByLanguage(Bip39Languages.english);
  return List<String>.generate(list.length(), (i) => list.getWordAtIdx(i),
      growable: false);
}();

/// Thrown when a mnemonic fails validation, with a user-presentable message.
class MnemonicValidationException implements Exception {
  const MnemonicValidationException(this.message);
  final String message;

  @override
  String toString() => 'MnemonicValidationException: $message';
}
