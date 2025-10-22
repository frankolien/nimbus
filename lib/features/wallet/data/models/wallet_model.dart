import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.address,
    super.name,
    super.isConnected,
    super.chainId,
    super.balance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      address: json['address'] as String,
      name: json['name'] as String?,
      isConnected: json['isConnected'] as bool? ?? false,
      chainId: json['chainId'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'isConnected': isConnected,
      'chainId': chainId,
      'balance': balance,
    };
  }

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      address: wallet.address,
      name: wallet.name,
      isConnected: wallet.isConnected,
      chainId: wallet.chainId,
      balance: wallet.balance,
    );
  }
}
