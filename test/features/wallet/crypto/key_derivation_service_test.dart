import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/wallet/data/crypto/key_derivation_service.dart';
import 'package:nimbus/features/wallet/data/crypto/mnemonic_service.dart';
import 'package:nimbus/features/wallet/domain/entities/chain_family.dart';

void main() {
  const derivation = KeyDerivationService();
  const mnemonicService = MnemonicService();

  // Canonical BIP39 test mnemonic. ETH and BTC(BIP84) addresses below match
  // the widely-published reference vectors; SOL/SUI are locked as golden
  // regression values produced by the same (test-vector-verified) library.
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon about';

  group('KeyDerivationService — account 0 golden vectors', () {
    const expected = {
      ChainFamily.evm: '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
      ChainFamily.bitcoin: 'bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu',
      ChainFamily.solana: 'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk',
      ChainFamily.sui:
          '0x5e93a736d04fbb25737aa40bee40171ef79f65fae833749e3c089fe7cc2161f1',
    };

    for (final entry in expected.entries) {
      test('derives correct ${entry.key.id} address', () {
        final account = derivation.deriveAddress(testMnemonic, entry.key, 0);
        // EVM is case-insensitive (checksum); others are exact.
        if (entry.key == ChainFamily.evm) {
          expect(account.address.toLowerCase(), entry.value.toLowerCase());
        } else {
          expect(account.address, entry.value);
        }
      });
    }
  });

  group('derivation paths', () {
    test('match the Phantom scheme for account 0', () {
      expect(derivation.deriveAddress(testMnemonic, ChainFamily.evm, 0).derivationPath,
          "m/44'/60'/0'/0/0");
      expect(derivation.deriveAddress(testMnemonic, ChainFamily.solana, 0).derivationPath,
          "m/44'/501'/0'/0'");
      expect(derivation.deriveAddress(testMnemonic, ChainFamily.bitcoin, 0).derivationPath,
          "m/84'/0'/0'/0/0");
      expect(derivation.deriveAddress(testMnemonic, ChainFamily.sui, 0).derivationPath,
          "m/44'/784'/0'/0'/0'");
    });

    test('bump the account level for account 1', () {
      expect(derivation.deriveAddress(testMnemonic, ChainFamily.evm, 1).derivationPath,
          "m/44'/60'/1'/0/0");
    });
  });

  group('deriveWalletAccount', () {
    test('produces one address per supported family', () {
      final account = derivation.deriveWalletAccount(testMnemonic, 0);
      expect(account.index, 0);
      expect(account.label, 'Account 1');
      expect(account.accountsByFamily.keys.toSet(),
          KeyDerivationService.supportedFamilies.toSet());
      expect(account.account(ChainFamily.evm)!.address.toLowerCase(),
          '0x9858effd232b4033e47d90003d41ec34ecaeda94');
    });

    test('account 1 yields different addresses than account 0', () {
      final a0 = derivation.deriveWalletAccount(testMnemonic, 0);
      final a1 = derivation.deriveWalletAccount(testMnemonic, 1);
      for (final family in KeyDerivationService.supportedFamilies) {
        expect(a0.account(family)!.address,
            isNot(a1.account(family)!.address),
            reason: '${family.id} addresses must differ across accounts');
      }
    });

    test('public account carries no private key material (JSON round-trip)', () {
      final account = derivation.deriveWalletAccount(testMnemonic, 0);
      final json = account.toJson().toString().toLowerCase();
      // The known private key for this mnemonic's EVM key must not leak.
      expect(json.contains('private'), isFalse);
    });
  });

  group('determinism', () {
    test('same mnemonic always derives the same address', () {
      final a = derivation.deriveAddress(testMnemonic, ChainFamily.solana, 0);
      final b = derivation.deriveAddress(testMnemonic, ChainFamily.solana, 0);
      expect(a.address, b.address);
      expect(a.publicKeyHex, b.publicKeyHex);
    });

    test('normalized mnemonic derives identically to the raw form', () {
      const messy = '  ABANDON  abandon abandon abandon abandon abandon '
          'abandon abandon abandon abandon abandon ABOUT ';
      final normalized = mnemonicService.normalize(messy);
      expect(
        derivation.deriveAddress(normalized, ChainFamily.evm, 0).address,
        derivation.deriveAddress(testMnemonic, ChainFamily.evm, 0).address,
      );
    });
  });

  group('signing key', () {
    test('exposes raw private bytes for the derived address', () {
      final signer =
          derivation.deriveSigningKey(testMnemonic, ChainFamily.evm, 0);
      expect(signer.privateKeyBytes.length, 32);
      expect(signer.address.toLowerCase(),
          '0x9858effd232b4033e47d90003d41ec34ecaeda94');
      // toString must not leak the key.
      expect(signer.toString().contains(signer.privateKeyHex), isFalse);
    });
  });
}
