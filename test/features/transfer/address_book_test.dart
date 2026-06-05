import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/transfer/domain/recent_recipient.dart';
import 'package:nimbus/features/transfer/domain/saved_address.dart';
import 'package:nimbus/features/wallet/domain/entities/chain_family.dart';

void main() {
  group('SavedAddress', () {
    test('round-trips through JSON', () {
      const a = SavedAddress(
          address: '0xAbc', label: 'My Ledger', family: ChainFamily.evm);
      final b = SavedAddress.fromJson(a.toJson());
      expect(b.address, a.address);
      expect(b.label, a.label);
      expect(b.family, a.family);
    });

    test('sameAs matches on address AND family', () {
      const a =
          SavedAddress(address: 'X', label: 'n', family: ChainFamily.solana);
      expect(a.sameAs('X', ChainFamily.solana), isTrue);
      expect(a.sameAs('X', ChainFamily.evm), isFalse);
      expect(a.sameAs('Y', ChainFamily.solana), isFalse);
    });
  });

  group('RecentRecipient', () {
    test('round-trips through JSON', () {
      const r = RecentRecipient(
          address: 'sol1', family: ChainFamily.solana, lastUsedAt: 123);
      final r2 = RecentRecipient.fromJson(r.toJson());
      expect(r2.address, 'sol1');
      expect(r2.family, ChainFamily.solana);
      expect(r2.lastUsedAt, 123);
    });
  });
}
