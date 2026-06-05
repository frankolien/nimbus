import '../../wallet/domain/entities/chain_family.dart';

/// An address the user has sent to, recorded automatically (most-recent first)
/// so repeat transfers are one tap. Deduped by address + family; [lastUsedAt]
/// is epoch milliseconds.
class RecentRecipient {
  const RecentRecipient({
    required this.address,
    required this.family,
    required this.lastUsedAt,
  });

  final String address;
  final ChainFamily family;
  final int lastUsedAt;

  Map<String, dynamic> toJson() =>
      {'address': address, 'family': family.id, 'lastUsedAt': lastUsedAt};

  factory RecentRecipient.fromJson(Map<String, dynamic> j) => RecentRecipient(
        address: j['address'] as String,
        family: ChainFamily.values.firstWhere((f) => f.id == j['family']),
        lastUsedAt: (j['lastUsedAt'] as num).toInt(),
      );
}
