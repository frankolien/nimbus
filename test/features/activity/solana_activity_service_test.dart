import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/activity/data/solana_activity_service.dart';
import 'package:nimbus/features/activity/domain/activity_item.dart';

/// A getTransaction response with one System transfer of [lamports] from
/// [source] to [destination].
Map<String, dynamic> _transferTx({
  required String source,
  required String destination,
  required int lamports,
  Object? err,
}) =>
    {
      'result': {
        'blockTime': 1716200000,
        'meta': {
          'err': err,
          'fee': 5000,
          'preBalances': [10000000000, 2000000000],
          'postBalances': [10000000000 - lamports - 5000, 2000000000 + lamports],
          'innerInstructions': <dynamic>[],
        },
        'transaction': {
          'signatures': ['SIG123'],
          'message': {
            'accountKeys': [
              {'pubkey': source, 'signer': true, 'writable': true},
              {'pubkey': destination, 'signer': false, 'writable': true},
            ],
            'instructions': [
              {
                'program': 'system',
                'programId': '11111111111111111111111111111111',
                'parsed': {
                  'type': 'transfer',
                  'info': {
                    'source': source,
                    'destination': destination,
                    'lamports': lamports,
                  },
                },
              },
            ],
          },
        },
      },
    };

void main() {
  group('SolanaActivityService.parseTransaction', () {
    test('classifies a sent transfer (user is the source)', () {
      final item = SolanaActivityService.parseTransaction(
          _transferTx(source: 'USER', destination: 'DEST', lamports: 2500000000),
          'USER');
      expect(item, isNotNull);
      expect(item!.kind, ActivityKind.sent);
      expect(item.counterparty, 'DEST');
      expect(item.amountSol, closeTo(2.5, 1e-9));
      expect(item.signature, 'SIG123');
      expect(item.timestamp, isNotNull);
    });

    test('classifies a received transfer (user is the destination)', () {
      final item = SolanaActivityService.parseTransaction(
          _transferTx(source: 'SENDER', destination: 'USER', lamports: 1000000000),
          'USER');
      expect(item!.kind, ActivityKind.received);
      expect(item.counterparty, 'SENDER');
      expect(item.amountSol, closeTo(1.0, 1e-9));
    });

    test('skips failed transactions', () {
      final item = SolanaActivityService.parseTransaction(
          _transferTx(
              source: 'USER',
              destination: 'DEST',
              lamports: 1000000000,
              err: {'InstructionError': <dynamic>[]}),
          'USER');
      expect(item, isNull);
    });

    test('skips transactions that do not involve the address', () {
      final item = SolanaActivityService.parseTransaction(
          _transferTx(source: 'A', destination: 'B', lamports: 1000000000),
          'USER');
      expect(item, isNull);
    });

    test('falls back to net balance delta when no parsed transfer', () {
      final json = {
        'result': {
          'blockTime': 1716200000,
          'meta': {
            'err': null,
            'fee': 5000,
            'preBalances': [5000000000, 1000000000],
            'postBalances': [3999995000, 2000000000],
            'innerInstructions': <dynamic>[],
          },
          'transaction': {
            'signatures': ['SIGX'],
            'message': {
              'accountKeys': [
                {'pubkey': 'OTHER'},
                {'pubkey': 'USER'},
              ],
              'instructions': [
                {'program': 'vote', 'parsed': null},
              ],
            },
          },
        },
      };
      final item = SolanaActivityService.parseTransaction(json, 'USER');
      expect(item, isNotNull);
      expect(item!.kind, ActivityKind.received);
      expect(item.amountSol, closeTo(1.0, 1e-9));
      expect(item.counterparty, 'OTHER');
    });

    test('returns null when only the fee moved (no SOL transfer)', () {
      final json = {
        'result': {
          'blockTime': 1716200000,
          'meta': {
            'err': null,
            'fee': 5000,
            'preBalances': [1000000000, 0],
            'postBalances': [999995000, 0],
            'innerInstructions': <dynamic>[],
          },
          'transaction': {
            'signatures': ['SIGY'],
            'message': {
              'accountKeys': [
                {'pubkey': 'USER'},
                {'pubkey': 'PROGRAM'},
              ],
              'instructions': [
                {'program': 'spl-token', 'parsed': null},
              ],
            },
          },
        },
      };
      expect(SolanaActivityService.parseTransaction(json, 'USER'), isNull);
    });
  });
}
