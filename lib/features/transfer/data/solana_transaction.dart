/// Serializes a Solana *legacy* transaction for a single native SOL transfer.
///
/// Solana has no Dart SDK in this project, so we build the wire format by hand
/// (it's small and stable). A transaction is `shortvec(signatures) ++ message`;
/// the signature is a raw ed25519 signature over the serialized [buildMessage].
///
/// Message layout (legacy):
///   header(3) ++ shortvec(accountKeys) ++ recentBlockhash(32) ++
///   shortvec(instructions)
/// For a transfer the accounts are ordered [from(signer,writable),
/// to(writable), SystemProgram(readonly)], and the single instruction is the
/// System Program's Transfer (index 2) carrying the lamports as a u64.
abstract final class SolanaTransfer {
  /// The System Program address is 32 zero bytes (base58 "111…11").
  static final List<int> systemProgramId = List<int>.filled(32, 0);

  /// Build the signable message bytes for a transfer of [lamports] from [from]
  /// to [to] against [recentBlockhash]. All three keys are raw 32-byte values.
  static List<int> buildMessage({
    required List<int> from,
    required List<int> to,
    required List<int> recentBlockhash,
    required BigInt lamports,
  }) {
    _require32('from', from);
    _require32('to', to);
    _require32('recentBlockhash', recentBlockhash);

    final keys = [from, to, systemProgramId];
    final out = <int>[
      // Message header.
      1, // numRequiredSignatures
      0, // numReadonlySignedAccounts
      1, // numReadonlyUnsignedAccounts (the System Program)
      // Account keys.
      ...shortVec(keys.length),
      for (final k in keys) ...k,
      // Recent blockhash.
      ...recentBlockhash,
      // Instructions (exactly one).
      ...shortVec(1),
      2, // programIdIndex → System Program (3rd key)
      ...shortVec(2), ...[0, 1], // account indices: from, to
    ];
    final data = <int>[2, 0, 0, 0, ...u64le(lamports)]; // Transfer + lamports
    out
      ..addAll(shortVec(data.length))
      ..addAll(data);
    return out;
  }

  /// Assemble the broadcastable transaction: one signature, then the message.
  static List<int> buildSignedTransaction({
    required List<int> message,
    required List<int> signature,
  }) {
    if (signature.length != 64) {
      throw ArgumentError('signature must be 64 bytes, got ${signature.length}');
    }
    return [...shortVec(1), ...signature, ...message];
  }

  /// Little-endian u64 encoding of [value] (8 bytes).
  static List<int> u64le(BigInt value) {
    if (value < BigInt.zero) throw ArgumentError('lamports must be >= 0');
    final mask = BigInt.from(0xff);
    final bytes = <int>[];
    var v = value;
    for (var i = 0; i < 8; i++) {
      bytes.add((v & mask).toInt());
      v >>= 8;
    }
    return bytes;
  }

  /// Compact-u16 ("shortvec") length prefix used throughout Solana's format.
  static List<int> shortVec(int length) {
    if (length < 0) throw ArgumentError('length must be >= 0');
    final out = <int>[];
    var rem = length;
    while (true) {
      final elem = rem & 0x7f;
      rem >>= 7;
      if (rem == 0) {
        out.add(elem);
        break;
      }
      out.add(elem | 0x80);
    }
    return out;
  }

  static void _require32(String name, List<int> bytes) {
    if (bytes.length != 32) {
      throw ArgumentError('$name must be 32 bytes, got ${bytes.length}');
    }
  }
}
