import 'dart:convert';

import 'package:argon2/argon2.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';

/// Encrypts a recovery phrase with a key derived from the user's passcode.
///
/// Scheme: argon2id(passcode, salt) -> 32-byte key, then AES-256-GCM over the
/// UTF-8 mnemonic. The GCM auth tag means a wrong passcode (or any tampering)
/// fails closed with [InvalidPasscodeException] rather than returning garbage.
///
/// The KDF cost parameters are stored alongside each blob so they can be raised
/// over time without breaking the ability to decrypt older wallets.
class SeedCipher {
  const SeedCipher({
    this.iterations = 3,
    this.memoryPow2 = 16, // 2^16 KiB = 64 MiB
    this.lanes = 4,
  });

  /// Lower-cost variant for unit tests; never use in production.
  const SeedCipher.fast()
      : iterations = 1,
        memoryPow2 = 8,
        lanes = 1;

  final int iterations;
  final int memoryPow2;
  final int lanes;

  static const int _keyLen = 32; // AES-256
  static const int _saltLen = 16;
  static const int _nonceLen = 12; // GCM standard
  static const int _schemaVersion = 1;

  /// Encrypt [mnemonic] under [passcode]. Generates fresh random salt + nonce.
  /// The argon2id KDF runs on a background isolate so the UI never blocks.
  Future<EncryptedSeed> encrypt(String mnemonic, String passcode) async {
    final salt = QuickCrypto.generateRandom(_saltLen);
    final nonce = QuickCrypto.generateRandom(_nonceLen);
    final key = await _deriveKey(passcode, salt, iterations, memoryPow2, lanes);
    try {
      final sealed = GCM(AES(key)).encrypt(nonce, utf8.encode(mnemonic));
      return EncryptedSeed(
        schemaVersion: _schemaVersion,
        salt: salt,
        nonce: nonce,
        ciphertext: sealed,
        iterations: iterations,
        memoryPow2: memoryPow2,
        lanes: lanes,
      );
    } finally {
      _zero(key);
    }
  }

  /// Decrypt [seed] with [passcode]. Throws [InvalidPasscodeException] if the
  /// passcode is wrong or the data has been tampered with.
  Future<String> decrypt(EncryptedSeed seed, String passcode) async {
    final key = await _deriveKey(
      passcode,
      seed.salt,
      seed.iterations,
      seed.memoryPow2,
      seed.lanes,
    );
    try {
      final plain = GCM(AES(key)).decrypt(seed.nonce, seed.ciphertext);
      if (plain == null) {
        throw const InvalidPasscodeException();
      }
      return utf8.decode(plain);
    } finally {
      _zero(key);
    }
  }

  /// Verify a passcode without exposing the mnemonic.
  Future<bool> verify(EncryptedSeed seed, String passcode) async {
    try {
      await decrypt(seed, passcode);
      return true;
    } on InvalidPasscodeException {
      return false;
    }
  }

  Future<List<int>> _deriveKey(
    String passcode,
    List<int> salt,
    int iterations,
    int memoryPow2,
    int lanes,
  ) {
    return compute(
      _argon2id,
      _KdfArgs(
        passcode: passcode,
        salt: salt,
        iterations: iterations,
        memoryPow2: memoryPow2,
        lanes: lanes,
        keyLen: _keyLen,
      ),
    );
  }

  void _zero(List<int> bytes) {
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }
}

/// Arguments for the isolate KDF. All fields are isolate-sendable.
class _KdfArgs {
  const _KdfArgs({
    required this.passcode,
    required this.salt,
    required this.iterations,
    required this.memoryPow2,
    required this.lanes,
    required this.keyLen,
  });
  final String passcode;
  final List<int> salt;
  final int iterations;
  final int memoryPow2;
  final int lanes;
  final int keyLen;
}

/// Top-level so it can run on a background isolate via [compute].
List<int> _argon2id(_KdfArgs a) {
  final params = Argon2Parameters(
    Argon2Parameters.ARGON2_id,
    Uint8List.fromList(a.salt),
    version: Argon2Parameters.ARGON2_VERSION_13,
    iterations: a.iterations,
    memoryPowerOf2: a.memoryPow2,
    lanes: a.lanes,
  );
  final generator = Argon2BytesGenerator()..init(params);
  final out = Uint8List(a.keyLen);
  generator.generateBytes(params.converter.convert(a.passcode), out, 0, out.length);
  return out;
}

/// The encrypted recovery phrase plus everything needed to decrypt it (except
/// the passcode). Safe to persist; useless without the passcode.
class EncryptedSeed {
  const EncryptedSeed({
    required this.schemaVersion,
    required this.salt,
    required this.nonce,
    required this.ciphertext,
    required this.iterations,
    required this.memoryPow2,
    required this.lanes,
  });

  final int schemaVersion;
  final List<int> salt;
  final List<int> nonce;
  final List<int> ciphertext;
  final int iterations;
  final int memoryPow2;
  final int lanes;

  Map<String, dynamic> toJson() => {
        'v': schemaVersion,
        'salt': base64Encode(salt),
        'nonce': base64Encode(nonce),
        'ct': base64Encode(ciphertext),
        'kdf': {
          'algo': 'argon2id',
          'iterations': iterations,
          'memoryPow2': memoryPow2,
          'lanes': lanes,
        },
      };

  String encode() => jsonEncode(toJson());

  factory EncryptedSeed.fromJson(Map<String, dynamic> json) {
    final kdf = json['kdf'] as Map<String, dynamic>;
    return EncryptedSeed(
      schemaVersion: json['v'] as int,
      salt: base64Decode(json['salt'] as String),
      nonce: base64Decode(json['nonce'] as String),
      ciphertext: base64Decode(json['ct'] as String),
      iterations: kdf['iterations'] as int,
      memoryPow2: kdf['memoryPow2'] as int,
      lanes: kdf['lanes'] as int,
    );
  }

  factory EncryptedSeed.decode(String raw) =>
      EncryptedSeed.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// Thrown when decryption fails — wrong passcode or tampered ciphertext.
class InvalidPasscodeException implements Exception {
  const InvalidPasscodeException();
  @override
  String toString() => 'InvalidPasscodeException: incorrect passcode';
}
