import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String address;
  final String? name;
  final bool isConnected;
  final String? chainId;
  final double? balance;

  const Wallet({
    required this.address,
    this.name,
    this.isConnected = false,
    this.chainId,
    this.balance,
  });

  @override
  List<Object?> get props => [address, name, isConnected, chainId, balance];

  Wallet copyWith({
    String? address,
    String? name,
    bool? isConnected,
    String? chainId,
    double? balance,
  }) {
    return Wallet(
      address: address ?? this.address,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      chainId: chainId ?? this.chainId,
      balance: balance ?? this.balance,
    );
  }
}
