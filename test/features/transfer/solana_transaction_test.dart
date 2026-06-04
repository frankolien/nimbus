import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/transfer/data/solana_send_service.dart';
import 'package:nimbus/features/transfer/data/solana_transaction.dart';

void main() {
  group('SolanaTransfer.shortVec', () {
    test('encodes compact-u16 lengths', () {
      expect(SolanaTransfer.shortVec(0), [0]);
      expect(SolanaTransfer.shortVec(1), [1]);
      expect(SolanaTransfer.shortVec(127), [127]);
      expect(SolanaTransfer.shortVec(128), [0x80, 0x01]);
      expect(SolanaTransfer.shortVec(256), [0x80, 0x02]);
    });
  });

  group('SolanaTransfer.u64le', () {
    test('little-endian 8-byte encoding', () {
      expect(SolanaTransfer.u64le(BigInt.zero), [0, 0, 0, 0, 0, 0, 0, 0]);
      expect(SolanaTransfer.u64le(BigInt.one), [1, 0, 0, 0, 0, 0, 0, 0]);
      expect(SolanaTransfer.u64le(BigInt.from(256)), [0, 1, 0, 0, 0, 0, 0, 0]);
      // 1 SOL = 1_000_000_000 lamports = 0x3B9ACA00.
      expect(SolanaTransfer.u64le(BigInt.from(1000000000)),
          [0, 202, 154, 59, 0, 0, 0, 0]);
    });

    test('rejects negative values', () {
      expect(() => SolanaTransfer.u64le(BigInt.from(-1)), throwsArgumentError);
    });
  });

  group('SolanaTransfer.buildMessage', () {
    final from = List<int>.generate(32, (i) => i + 1);
    final to = List<int>.filled(32, 0xAA);
    final blockhash = List<int>.filled(32, 0xBB);

    test('serializes a single transfer into the legacy layout', () {
      final msg = SolanaTransfer.buildMessage(
        from: from,
        to: to,
        recentBlockhash: blockhash,
        lamports: BigInt.from(1000000000),
      );

      // header(3) + shortvec(1) + keys(96) + blockhash(32) + ix(18) = 150
      expect(msg.length, 150);
      expect(msg.sublist(0, 3), [1, 0, 1]); // 1 signer, 1 readonly-unsigned
      expect(msg[3], 3); // three account keys
      expect(msg.sublist(4, 36), from);
      expect(msg.sublist(36, 68), to);
      expect(msg.sublist(68, 100), List<int>.filled(32, 0)); // System Program
      expect(msg.sublist(100, 132), blockhash);
      expect(msg[132], 1); // one instruction
      expect(msg[133], 2); // programIdIndex → System Program
      expect(msg[134], 2); // two account indices
      expect(msg.sublist(135, 137), [0, 1]); // from, to
      expect(msg[137], 12); // data length
      expect(msg.sublist(138, 142), [2, 0, 0, 0]); // Transfer discriminator
      expect(msg.sublist(142, 150), [0, 202, 154, 59, 0, 0, 0, 0]); // lamports
    });

    test('rejects keys that are not 32 bytes', () {
      expect(
        () => SolanaTransfer.buildMessage(
          from: const [1, 2, 3],
          to: to,
          recentBlockhash: blockhash,
          lamports: BigInt.one,
        ),
        throwsArgumentError,
      );
    });
  });

  group('SolanaTransfer.buildSignedTransaction', () {
    test('prefixes one signature before the message', () {
      final sig = List<int>.filled(64, 7);
      final message = List<int>.filled(150, 9);
      final tx =
          SolanaTransfer.buildSignedTransaction(message: message, signature: sig);
      expect(tx[0], 1); // one signature
      expect(tx.sublist(1, 65), sig);
      expect(tx.sublist(65), message);
    });

    test('rejects a signature that is not 64 bytes', () {
      expect(
        () => SolanaTransfer.buildSignedTransaction(
            message: const [], signature: List<int>.filled(63, 0)),
        throwsArgumentError,
      );
    });
  });

  group('SolanaSendService.isValidAddress', () {
    test('accepts a real base58 Solana address', () {
      expect(
          SolanaSendService.isValidAddress(
              'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk'),
          isTrue);
    });

    test('rejects an EVM hex address and empty input', () {
      expect(
          SolanaSendService.isValidAddress(
              '0x71C7656EC7ab88b098defB751B7401B5f6d8976F'),
          isFalse);
      expect(SolanaSendService.isValidAddress(''), isFalse);
    });
  });
}
