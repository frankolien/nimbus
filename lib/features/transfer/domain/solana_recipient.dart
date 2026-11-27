// Local checks for Solana recipients: a base58 address that decodes to 32
// bytes, or a `.sol` name that Xend resolves at send time.

const _alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Decodes base58, or returns null on any character outside the alphabet.
List<int>? _base58Decode(String s) {
  var n = BigInt.zero;
  for (final ch in s.split('')) {
    final i = _alphabet.indexOf(ch);
    if (i < 0) return null;
    n = n * BigInt.from(58) + BigInt.from(i);
  }
  final bytes = <int>[];
  while (n > BigInt.zero) {
    bytes.insert(0, (n & BigInt.from(0xff)).toInt());
    n = n >> 8;
  }
  // Each leading '1' is a leading zero byte.
  for (var i = 0; i < s.length && s[i] == '1'; i++) {
    bytes.insert(0, 0);
  }
  return bytes;
}

/// True for a base58 string that decodes to a 32-byte public key.
bool isSolanaAddress(String value) {
  final s = value.trim();
  if (s.length < 32 || s.length > 44) return false;
  return _base58Decode(s)?.length == 32;
}

/// True for something shaped like a Solana Name Service domain, e.g. `gift.sol`.
/// Whether it is registered is only known after resolving it.
bool isSolName(String value) =>
    RegExp(r'^([a-z0-9-]+\.)+sol$').hasMatch(value.trim().toLowerCase());

/// True if [value] can be passed to `XendWallet.send` as a recipient.
bool isValidSolanaRecipient(String value) =>
    isSolanaAddress(value) || isSolName(value);
