import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/wallet/data/crypto/key_derivation_service.dart';
import 'package:nimbus/features/wallet/data/crypto/seed_cipher.dart';
import 'package:nimbus/features/wallet/data/storage/seed_vault.dart';
import 'package:nimbus/features/wallet/data/wallet_vault.dart';
import 'package:nimbus/features/wallet/domain/entities/chain_family.dart';
import 'package:nimbus/features/wallet/domain/entities/wallet_account.dart';

/// In-memory [SeedVault] for testing — mirrors the real storage contract
/// without touching platform channels.
class FakeSeedVault implements SeedVault {
  String? seed;
  String? accountsJson;

  @override
  Future<bool> hasWallet() async => seed != null;

  @override
  Future<void> writeEncryptedSeed(String encodedBlob) async => seed = encodedBlob;

  @override
  Future<String?> readEncryptedSeed() async => seed;

  @override
  Future<void> writeAccounts(List<WalletAccount> accounts) async {
    accountsJson = accounts.map((a) => a.toJson()).toString();
    _accounts = List.of(accounts);
  }

  List<WalletAccount> _accounts = const [];

  @override
  Future<List<WalletAccount>> readAccounts() async => _accounts;

  @override
  Future<void> clear() async {
    seed = null;
    accountsJson = null;
    _accounts = const [];
  }
}

void main() {
  const mnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon about';
  const passcode = '135790';

  late FakeSeedVault vault;
  late WalletVault wallet;

  setUp(() {
    vault = FakeSeedVault();
    wallet = WalletVault(vault: vault, cipher: const SeedCipher.fast());
  });

  test('no wallet exists initially', () async {
    expect(await wallet.hasWallet(), isFalse);
    expect(wallet.isUnlocked, isFalse);
  });

  test('createWallet persists encrypted seed, derives accounts, unlocks',
      () async {
    final accounts = await wallet.createWallet(
      mnemonic: mnemonic,
      passcode: passcode,
    );
    expect(accounts, hasLength(1));
    expect(accounts.first.accountsByFamily.keys.toSet(),
        KeyDerivationService.supportedFamilies.toSet());
    expect(await wallet.hasWallet(), isTrue);
    expect(wallet.isUnlocked, isTrue);
    // Stored blob must not contain the plaintext phrase.
    expect(vault.seed!.contains('abandon'), isFalse);
  });

  test('createWallet rejects an invalid mnemonic', () async {
    expect(
      () => wallet.createWallet(mnemonic: 'not a real phrase', passcode: passcode),
      throwsA(anything),
    );
    expect(await wallet.hasWallet(), isFalse);
  });

  test('unlock with correct passcode restores accounts', () async {
    await wallet.createWallet(mnemonic: mnemonic, passcode: passcode);
    wallet.lock();
    expect(wallet.isUnlocked, isFalse);

    final accounts = await wallet.unlock(passcode);
    expect(wallet.isUnlocked, isTrue);
    expect(accounts.first.account(ChainFamily.evm)!.address.toLowerCase(),
        '0x9858effd232b4033e47d90003d41ec34ecaeda94');
  });

  test('unlock with wrong passcode throws and stays locked', () async {
    await wallet.createWallet(mnemonic: mnemonic, passcode: passcode);
    wallet.lock();
    expect(() => wallet.unlock('000000'),
        throwsA(isA<InvalidPasscodeException>()));
    expect(wallet.isUnlocked, isFalse);
  });

  test('unlock with no wallet throws NoWalletException', () async {
    expect(() => wallet.unlock(passcode), throwsA(isA<NoWalletException>()));
  });

  test('signingKey requires an unlocked session', () async {
    await wallet.createWallet(mnemonic: mnemonic, passcode: passcode);
    wallet.lock();
    expect(() => wallet.signingKey(ChainFamily.evm, 0),
        throwsA(isA<VaultLockedException>()));

    await wallet.unlock(passcode);
    final key = wallet.signingKey(ChainFamily.evm, 0);
    expect(key.privateKeyBytes, hasLength(32));
    expect(key.address.toLowerCase(),
        '0x9858effd232b4033e47d90003d41ec34ecaeda94');
  });

  test('addAccount derives the next sequential index', () async {
    await wallet.createWallet(mnemonic: mnemonic, passcode: passcode);
    final second = await wallet.addAccount();
    expect(second.index, 1);
    expect(second.label, 'Account 2');
    expect(await vault.readAccounts(), hasLength(2));
  });

  test('revealRecoveryPhrase returns the phrase only with right passcode',
      () async {
    await wallet.createWallet(mnemonic: mnemonic, passcode: passcode);
    expect(await wallet.revealRecoveryPhrase(passcode), mnemonic);
    expect(() => wallet.revealRecoveryPhrase('000000'),
        throwsA(isA<InvalidPasscodeException>()));
  });

  test('importWallet behaves like create for an existing phrase', () async {
    final accounts =
        await wallet.importWallet(mnemonic: mnemonic, passcode: passcode);
    expect(accounts.first.account(ChainFamily.solana)!.address,
        'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk');
  });

  test('deleteWallet wipes storage and locks', () async {
    await wallet.createWallet(mnemonic: mnemonic, passcode: passcode);
    await wallet.deleteWallet();
    expect(await wallet.hasWallet(), isFalse);
    expect(wallet.isUnlocked, isFalse);
  });
}
