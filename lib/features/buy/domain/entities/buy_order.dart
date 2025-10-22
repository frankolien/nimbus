import 'package:equatable/equatable.dart';

class BuyOrder extends Equatable {
  final String id;
  final String tokenSymbol;
  final double amount;
  final double price;
  final String paymentMethod;
  final DateTime createdAt;
  final BuyOrderStatus status;

  const BuyOrder({
    required this.id,
    required this.tokenSymbol,
    required this.amount,
    required this.price,
    required this.paymentMethod,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        tokenSymbol,
        amount,
        price,
        paymentMethod,
        createdAt,
        status,
      ];
}

enum BuyOrderStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}
