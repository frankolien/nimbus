import 'package:equatable/equatable.dart';

import 'blockchain_account.dart';
import 'chain_family.dart';

/// A Phantom-style "account": a single index across the shared recovery phrase
/// that yields one [BlockchainAccount] per supported [ChainFamily].
///
/// Account 0 is the default. Creating "Account 2" simply bumps [index]; every
/// account is recoverable from the same seed, so we persist only public data.
class WalletAccount extends Equatable {
  const WalletAccount({
    required this.index,
    required this.label,
    required this.accountsByFamily,
  });

  /// 0-based account index used in derivation paths.
  final int index;

  /// User-facing label, e.g. "Account 1".
  final String label;

  /// One derived address per family. Keyed by family for O(1) lookup.
  final Map<ChainFamily, BlockchainAccount> accountsByFamily;

  /// The derived address for [family], or null if not derived.
  BlockchainAccount? account(ChainFamily family) => accountsByFamily[family];

  List<BlockchainAccount> get accounts => accountsByFamily.values.toList();

  WalletAccount copyWith({String? label}) => WalletAccount(
        index: index,
        label: label ?? this.label,
        accountsByFamily: accountsByFamily,
      );

  @override
  List<Object?> get props => [index, label, accountsByFamily];

  Map<String, dynamic> toJson() => {
        'index': index,
        'label': label,
        'accounts':
            accountsByFamily.values.map((a) => a.toJson()).toList(),
      };

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    final accounts = (json['accounts'] as List)
        .map((e) => BlockchainAccount.fromJson(e as Map<String, dynamic>))
        .toList();
    return WalletAccount(
      index: json['index'] as int,
      label: json['label'] as String,
      accountsByFamily: {for (final a in accounts) a.family: a},
    );
  }
}
