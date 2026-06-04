import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/core/utils/formatters.dart';

void main() {
  group('Fmt.marketPrice', () {
    test('full price at or above one dollar', () {
      expect(Fmt.marketPrice(176.42), '\$176.42');
      expect(Fmt.marketPrice(3512), '\$3,512.00');
    });

    test('sub-dollar keeps four decimals, trims trailing zeros', () {
      expect(Fmt.marketPrice(0.9912), '\$0.9912');
      expect(Fmt.marketPrice(0.5), '\$0.5');
    });

    test('micro-cap shows enough significant figures', () {
      expect(Fmt.marketPrice(0.000031), '\$0.000031');
    });

    test('zero', () {
      expect(Fmt.marketPrice(0), '\$0');
    });
  });

  group('Fmt.address', () {
    test('truncates a long address keeping head and tail', () {
      const sol = '7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU';
      expect(Fmt.address(sol), '7xKXtg…gAsU');
    });

    test('respects custom head/tail lengths', () {
      const evm = '0x71C7656EC7ab88b098defB751B7401B5f6d8976F';
      expect(Fmt.address(evm, head: 4, tail: 4), '0x71…976F');
    });

    test('returns short values unchanged', () {
      expect(Fmt.address('0xABCD'), '0xABCD');
    });

    test('does not truncate when length equals head + tail + 1', () {
      // 11 chars, head 6 + tail 4 + the ellipsis slot.
      expect(Fmt.address('abcdefghijk'), 'abcdefghijk');
    });

    test('uses a single-character ellipsis', () {
      final out = Fmt.address('0123456789ABCDEFGHIJ');
      expect(out.contains('…'), isTrue);
      expect(out.contains('...'), isFalse);
    });
  });
}
