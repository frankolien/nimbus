import 'package:equatable/equatable.dart';

class CryptoAsset extends Equatable {
  final String symbol;
  final String name;
  final String iconPath;
  final String category;
  final double price;
  final double balance;

  const CryptoAsset({
    required this.symbol,
    required this.name,
    required this.iconPath,
    required this.category,
    required this.price,
    required this.balance,
  });

  @override
  List<Object?> get props => [
        symbol,
        name,
        iconPath,
        category,
        price,
        balance,
      ];
}
