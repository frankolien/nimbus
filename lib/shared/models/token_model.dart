import '../entities/token.dart';

class TokenModel extends Token {
  const TokenModel({
    required super.address,
    required super.symbol,
    required super.name,
    required super.decimals,
    super.logoUrl,
    super.balance,
    super.priceUsd,
    required super.chainId,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      address: json['address'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      decimals: json['decimals'] as int,
      logoUrl: json['logoUrl'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      priceUsd: (json['priceUsd'] as num?)?.toDouble(),
      chainId: json['chainId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'symbol': symbol,
      'name': name,
      'decimals': decimals,
      'logoUrl': logoUrl,
      'balance': balance,
      'priceUsd': priceUsd,
      'chainId': chainId,
    };
  }

  factory TokenModel.fromEntity(Token token) {
    return TokenModel(
      address: token.address,
      symbol: token.symbol,
      name: token.name,
      decimals: token.decimals,
      logoUrl: token.logoUrl,
      balance: token.balance,
      priceUsd: token.priceUsd,
      chainId: token.chainId,
    );
  }
}
