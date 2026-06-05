import '../../wallet/domain/entities/chain_family.dart';

/// A user-saved recipient: an address with a friendly [label], scoped to a
/// [family] so a SOL send only offers Solana addresses, an EVM send only EVM,
/// and so on.
class SavedAddress {
  const SavedAddress({
    required this.address,
    required this.label,
    required this.family,
  });

  final String address;
  final String label;
  final ChainFamily family;

  SavedAddress copyWith({String? address, String? label}) => SavedAddress(
        address: address ?? this.address,
        label: label ?? this.label,
        family: family,
      );

  /// True when this entry points at the same address on the same chain family.
  bool sameAs(String otherAddress, ChainFamily otherFamily) =>
      address == otherAddress && family == otherFamily;

  Map<String, dynamic> toJson() =>
      {'address': address, 'label': label, 'family': family.id};

  factory SavedAddress.fromJson(Map<String, dynamic> j) => SavedAddress(
        address: j['address'] as String,
        label: j['label'] as String,
        family: ChainFamily.values.firstWhere((f) => f.id == j['family']),
      );
}
