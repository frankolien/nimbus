import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/portfolio/data/solana_account_stream.dart';

void main() {
  group('SolanaAccountStream.wsUrl', () {
    test('upgrades https to wss', () {
      expect(SolanaAccountStream.wsUrl('https://api.devnet.solana.com'),
          'wss://api.devnet.solana.com');
    });

    test('upgrades http to ws', () {
      expect(SolanaAccountStream.wsUrl('http://localhost:8899'),
          'ws://localhost:8899');
    });

    test('preserves path + query for keyed providers', () {
      expect(
        SolanaAccountStream.wsUrl('https://mainnet.helius-rpc.com/?api-key=abc'),
        'wss://mainnet.helius-rpc.com/?api-key=abc',
      );
    });
  });

  group('SolanaAccountStream.parseBalance', () {
    test('reads lamports + slot from an accountNotification', () {
      const frame = '{"jsonrpc":"2.0","method":"accountNotification","params":'
          '{"result":{"context":{"slot":42},"value":{"lamports":1500000000,'
          '"owner":"x","data":["","base64"]}},"subscription":7}}';
      final update = SolanaAccountStream.parseBalance(frame);
      expect(update, isNotNull);
      expect(update!.sol, closeTo(1.5, 1e-9));
      expect(update.slot, 42);
    });

    test('returns null for the subscription ack', () {
      expect(
        SolanaAccountStream.parseBalance('{"jsonrpc":"2.0","result":1,"id":1}'),
        isNull,
      );
    });

    test('returns null when the slot is missing', () {
      expect(
        SolanaAccountStream.parseBalance(
            '{"method":"accountNotification","params":{"result":{"value":{"lamports":5}}}}'),
        isNull,
      );
    });

    test('returns null for malformed or unrelated frames', () {
      expect(SolanaAccountStream.parseBalance('not json'), isNull);
      expect(
        SolanaAccountStream.parseBalance('{"method":"accountNotification"}'),
        isNull,
      );
    });
  });
}
