import 'package:equatable/equatable.dart';

class SendTransaction extends Equatable {
  final String id;
  final String toAddress;
  final String tokenSymbol;
  final double amount;
  final double gasFee;
  final DateTime createdAt;
  final TransactionStatus status;
  final String? txHash;

  const SendTransaction({
    required this.id,
    required this.toAddress,
    required this.tokenSymbol,
    required this.amount,
    required this.gasFee,
    required this.createdAt,
    required this.status,
    this.txHash,
  });

  @override
  List<Object?> get props => [
        id,
        toAddress,
        tokenSymbol,
        amount,
        gasFee,
        createdAt,
        status,
        txHash,
      ];
}

enum TransactionStatus {
  pending,
  confirmed,
  failed,
}
