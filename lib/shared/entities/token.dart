import 'package:equatable/equatable.dart';

class Token extends Equatable {
  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final String? logoUrl;
  final double? balance;
  final double? priceUsd;
  final String chainId;

  const Token({
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    this.logoUrl,
    this.balance,
    this.priceUsd,
    required this.chainId,
  });

  @override
  List<Object?> get props => [
        address,
        symbol,
        name,
        decimals,
        logoUrl,
        balance,
        priceUsd,
        chainId,
      ];

  Token copyWith({
    String? address,
    String? symbol,
    String? name,
    int? decimals,
    String? logoUrl,
    double? balance,
    double? priceUsd,
    String? chainId,
  }) {
    return Token(
      address: address ?? this.address,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      decimals: decimals ?? this.decimals,
      logoUrl: logoUrl ?? this.logoUrl,
      balance: balance ?? this.balance,
      priceUsd: priceUsd ?? this.priceUsd,
      chainId: chainId ?? this.chainId,
    );
  }
}
