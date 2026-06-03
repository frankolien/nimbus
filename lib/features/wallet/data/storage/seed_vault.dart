import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/wallet_account.dart';

/// Persistence boundary for the wallet's secrets and public metadata.
///
/// Deals only in already-encrypted blobs (the encoded [EncryptedSeed] string)
/// and public account JSON, so it never sees a plaintext mnemonic or private
/// key. Abstract so the orchestrator can be unit-tested with an in-memory fake.
abstract class SeedVault {
  Future<bool> hasWallet();

  /// Store the encoded, encrypted seed blob (see SeedCipher.encode()).
  Future<void> writeEncryptedSeed(String encodedBlob);
  Future<String?> readEncryptedSeed();

  /// Store/read the public account list (addresses only — no secrets).
  Future<void> writeAccounts(List<WalletAccount> accounts);
  Future<List<WalletAccount>> readAccounts();

  /// Wipe everything. Irreversible without the recovery phrase.
  Future<void> clear();
}

/// [SeedVault] backed by the OS keychain/keystore via flutter_secure_storage.
class SecureSeedVault implements SeedVault {
  SecureSeedVault({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _seedKey = 'nimbus.seed.v1';
  static const _accountsKey = 'nimbus.accounts.v1';

  @override
  Future<bool> hasWallet() => _storage.containsKey(key: _seedKey);

  @override
  Future<void> writeEncryptedSeed(String encodedBlob) =>
      _storage.write(key: _seedKey, value: encodedBlob);

  @override
  Future<String?> readEncryptedSeed() => _storage.read(key: _seedKey);

  @override
  Future<void> writeAccounts(List<WalletAccount> accounts) {
    final raw = jsonEncode(accounts.map((a) => a.toJson()).toList());
    return _storage.write(key: _accountsKey, value: raw);
  }

  @override
  Future<List<WalletAccount>> readAccounts() async {
    final raw = await _storage.read(key: _accountsKey);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => WalletAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _seedKey);
    await _storage.delete(key: _accountsKey);
  }
}
