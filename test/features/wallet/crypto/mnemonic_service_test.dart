import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/wallet/data/crypto/mnemonic_service.dart';

void main() {
  const service = MnemonicService();

  const validMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon about';

  group('generate', () {
    test('produces a valid 12-word mnemonic by default', () {
      final m = service.generate();
      expect(m.split(' ').length, 12);
      expect(service.isValid(m), isTrue);
    });

    test('produces a valid 24-word mnemonic when asked', () {
      final m = service.generate(wordCount: 24);
      expect(m.split(' ').length, 24);
      expect(service.isValid(m), isTrue);
    });

    test('rejects unsupported word counts', () {
      expect(() => service.generate(wordCount: 13), throwsArgumentError);
    });

    test('generates distinct phrases each call', () {
      expect(service.generate(), isNot(service.generate()));
    });
  });

  group('isValid', () {
    test('accepts a known-good phrase', () {
      expect(service.isValid(validMnemonic), isTrue);
    });

    test('rejects a phrase with a bad checksum', () {
      const bad =
          'abandon abandon abandon abandon abandon abandon abandon abandon '
          'abandon abandon abandon abandon'; // last word breaks checksum
      expect(service.isValid(bad), isFalse);
    });

    test('rejects a non-wordlist word', () {
      const bad =
          'zzzzz abandon abandon abandon abandon abandon abandon abandon '
          'abandon abandon abandon about';
      expect(service.isValid(bad), isFalse);
    });

    test('rejects wrong length', () {
      expect(service.isValid('abandon about'), isFalse);
    });
  });

  group('normalize', () {
    test('trims, lowercases, and collapses whitespace', () {
      expect(
        service.normalize('  ABANDON   abandon\tABOUT  '),
        'abandon abandon about',
      );
    });

    test('a normalized messy phrase validates', () {
      final messy = '  ${validMnemonic.toUpperCase()}  ';
      expect(service.isValid(messy), isTrue);
    });
  });

  group('validateOrThrow', () {
    test('passes for a valid phrase', () {
      expect(() => service.validateOrThrow(validMnemonic), returnsNormally);
    });

    test('throws with a message for wrong word count', () {
      expect(
        () => service.validateOrThrow('abandon about'),
        throwsA(isA<MnemonicValidationException>()),
      );
    });

    test('throws for a checksum failure', () {
      const bad =
          'abandon abandon abandon abandon abandon abandon abandon abandon '
          'abandon abandon abandon abandon';
      expect(
        () => service.validateOrThrow(bad),
        throwsA(isA<MnemonicValidationException>()),
      );
    });
  });

  group('suggestions', () {
    test('returns words starting with the prefix', () {
      final s = service.suggestions('aba');
      expect(s, isNotEmpty);
      expect(s.every((w) => w.startsWith('aba')), isTrue);
      expect(s.contains('abandon'), isTrue);
    });

    test('returns empty for empty prefix', () {
      expect(service.suggestions(''), isEmpty);
    });

    test('respects the limit', () {
      expect(service.suggestions('a', limit: 3).length, lessThanOrEqualTo(3));
    });
  });
}
