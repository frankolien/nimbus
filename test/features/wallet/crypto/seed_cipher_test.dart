import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/wallet/data/crypto/seed_cipher.dart';

void main() {
  // Use the fast KDF variant so tests stay quick; production uses 64 MiB argon2id.
  const cipher = SeedCipher.fast();

  const mnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon '
      'abandon abandon abandon about';
  const passcode = '135790';

  test('round-trips a mnemonic with the correct passcode', () async {
    final sealed = await cipher.encrypt(mnemonic, passcode);
    expect(await cipher.decrypt(sealed, passcode), mnemonic);
  });

  test('wrong passcode throws InvalidPasscodeException', () async {
    final sealed = await cipher.encrypt(mnemonic, passcode);
    expect(
      () => cipher.decrypt(sealed, '000000'),
      throwsA(isA<InvalidPasscodeException>()),
    );
  });

  test('verify() returns true/false without exposing the seed', () async {
    final sealed = await cipher.encrypt(mnemonic, passcode);
    expect(await cipher.verify(sealed, passcode), isTrue);
    expect(await cipher.verify(sealed, 'nope'), isFalse);
  });

  test('ciphertext does not contain the plaintext mnemonic', () async {
    final sealed = await cipher.encrypt(mnemonic, passcode);
    expect(sealed.encode().contains('abandon'), isFalse);
    expect(sealed.encode().contains('about'), isFalse);
  });

  test('each encryption uses fresh salt and nonce', () async {
    final a = await cipher.encrypt(mnemonic, passcode);
    final b = await cipher.encrypt(mnemonic, passcode);
    expect(a.salt, isNot(b.salt));
    expect(a.nonce, isNot(b.nonce));
    expect(a.ciphertext, isNot(b.ciphertext));
  });

  test('tampered ciphertext fails the GCM auth tag', () async {
    final sealed = await cipher.encrypt(mnemonic, passcode);
    final tampered = EncryptedSeed(
      schemaVersion: sealed.schemaVersion,
      salt: sealed.salt,
      nonce: sealed.nonce,
      ciphertext: [...sealed.ciphertext]..[0] ^= 0xFF,
      iterations: sealed.iterations,
      memoryPow2: sealed.memoryPow2,
      lanes: sealed.lanes,
    );
    expect(
      () => cipher.decrypt(tampered, passcode),
      throwsA(isA<InvalidPasscodeException>()),
    );
  });

  test('JSON encode/decode preserves the blob and stays decryptable', () async {
    final sealed = await cipher.encrypt(mnemonic, passcode);
    final restored = EncryptedSeed.decode(sealed.encode());
    expect(restored.iterations, sealed.iterations);
    expect(restored.memoryPow2, sealed.memoryPow2);
    expect(await cipher.decrypt(restored, passcode), mnemonic);
  });

  test('decrypt uses KDF params stored in the blob, not the cipher defaults',
      () async {
    // Encrypt with fast params, decrypt with a default-config cipher instance.
    final sealed = await cipher.encrypt(mnemonic, passcode);
    const other = SeedCipher(); // production params
    expect(await other.decrypt(sealed, passcode), mnemonic);
  });
}
