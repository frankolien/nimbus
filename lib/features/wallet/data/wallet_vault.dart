import '../domain/entities/chain_family.dart';
import '../domain/entities/wallet_account.dart';
import 'crypto/key_derivation_service.dart';
import 'crypto/mnemonic_service.dart';
import 'crypto/seed_cipher.dart';
import 'storage/seed_vault.dart';

/// The single entry point for everything secret in the wallet.
///
/// Responsibilities:
///  - create / import a wallet (encrypt the phrase, derive + persist accounts)
///  - unlock / lock (decrypt the phrase into an in-memory session)
///  - hand out transient signing keys while unlocked
///  - reveal the recovery phrase after a passcode re-check
///
/// The decrypted mnemonic lives only in [_sessionMnemonic] while unlocked and
/// is dropped on [lock]. Nothing here ever logs key material.
class WalletVault {
  WalletVault({
    required SeedVault vault,
    SeedCipher cipher = const SeedCipher(),
    KeyDerivationService derivation = const KeyDerivationService(),
    MnemonicService mnemonics = const MnemonicService(),
  })  : _vault = vault,
        _cipher = cipher,
        _derivation = derivation,
        _mnemonics = mnemonics;

  final SeedVault _vault;
  final SeedCipher _cipher;
  final KeyDerivationService _derivation;
  final MnemonicService _mnemonics;

  String? _sessionMnemonic;

  bool get isUnlocked => _sessionMnemonic != null;

  Future<bool> hasWallet() => _vault.hasWallet();

  /// Create a brand-new wallet from a freshly generated [mnemonic] (the one the
  /// user just backed up) protected by [passcode]. Returns the derived accounts
  /// and leaves the vault unlocked.
  Future<List<WalletAccount>> createWallet({
    required String mnemonic,
    required String passcode,
    int accountCount = 1,
  }) {
    return _persistNewWallet(
      mnemonic: _mnemonics.normalize(mnemonic),
      passcode: passcode,
      accountCount: accountCount,
      validate: true,
    );
  }

  /// Import an existing wallet from a user-entered [mnemonic].
  Future<List<WalletAccount>> importWallet({
    required String mnemonic,
    required String passcode,
    int accountCount = 1,
  }) {
    return _persistNewWallet(
      mnemonic: _mnemonics.normalize(mnemonic),
      passcode: passcode,
      accountCount: accountCount,
      validate: true,
    );
  }

  Future<List<WalletAccount>> _persistNewWallet({
    required String mnemonic,
    required String passcode,
    required int accountCount,
    required bool validate,
  }) async {
    if (validate) _mnemonics.validateOrThrow(mnemonic);
    final sealed = await _cipher.encrypt(mnemonic, passcode);
    await _vault.writeEncryptedSeed(sealed.encode());

    final accounts = [
      for (var i = 0; i < accountCount; i++)
        _derivation.deriveWalletAccount(mnemonic, i),
    ];
    await _vault.writeAccounts(accounts);

    _sessionMnemonic = mnemonic;
    return accounts;
  }

  /// Decrypt the stored phrase with [passcode] and start a session.
  /// Throws [NoWalletException] if none exists, or [InvalidPasscodeException].
  Future<List<WalletAccount>> unlock(String passcode) async {
    final blob = await _vault.readEncryptedSeed();
    if (blob == null) throw const NoWalletException();
    _sessionMnemonic =
        await _cipher.decrypt(EncryptedSeed.decode(blob), passcode);
    final accounts = await _vault.readAccounts();
    // Self-heal if account metadata is missing (e.g. older install).
    if (accounts.isEmpty) {
      final derived = _derivation.deriveWalletAccount(_sessionMnemonic!, 0);
      await _vault.writeAccounts([derived]);
      return [derived];
    }
    return accounts;
  }

  /// End the session and drop the in-memory phrase.
  void lock() => _sessionMnemonic = null;

  /// Add the next sequential account (Account N+1) while unlocked.
  Future<WalletAccount> addAccount({String? label}) async {
    final mnemonic = _requireUnlocked();
    final existing = await _vault.readAccounts();
    final nextIndex =
        existing.isEmpty ? 0 : existing.map((a) => a.index).reduce((a, b) => a > b ? a : b) + 1;
    final account =
        _derivation.deriveWalletAccount(mnemonic, nextIndex, label: label);
    await _vault.writeAccounts([...existing, account]);
    return account;
  }

  /// A transient signing key for [family]/[accountIndex]. Requires an unlocked
  /// session. Use immediately; do not retain.
  DerivedSigningKey signingKey(ChainFamily family, int accountIndex) =>
      _derivation.deriveSigningKey(_requireUnlocked(), family, accountIndex);

  /// Reveal the recovery phrase for backup, after re-checking [passcode].
  Future<String> revealRecoveryPhrase(String passcode) async {
    final blob = await _vault.readEncryptedSeed();
    if (blob == null) throw const NoWalletException();
    return _cipher.decrypt(EncryptedSeed.decode(blob), passcode);
  }

  /// Permanently erase the wallet from this device.
  Future<void> deleteWallet() async {
    await _vault.clear();
    lock();
  }

  String _requireUnlocked() {
    final m = _sessionMnemonic;
    if (m == null) throw const VaultLockedException();
    return m;
  }
}

/// No wallet exists on this device yet.
class NoWalletException implements Exception {
  const NoWalletException();
  @override
  String toString() => 'NoWalletException: no wallet on this device';
}

/// An operation needing the phrase was attempted while locked.
class VaultLockedException implements Exception {
  const VaultLockedException();
  @override
  String toString() => 'VaultLockedException: wallet is locked';
}
