import 'package:equatable/equatable.dart';

enum TransactionStatus {
  pending,
  confirmed,
  failed,
  cancelled,
}

enum TransactionType {
  send,
  receive,
  swap,
  buy,
}

class Transaction extends Equatable {
  final String hash;
  final String from;
  final String to;
  final String amount;
  final String tokenSymbol;
  final String tokenAddress;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? blockNumber;
  final String? gasUsed;
  final String? gasPrice;
  final String chainId;

  const Transaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.amount,
    required this.tokenSymbol,
    required this.tokenAddress,
    required this.type,
    required this.status,
    required this.timestamp,
    this.blockNumber,
    this.gasUsed,
    this.gasPrice,
    required this.chainId,
  });

  @override
  List<Object?> get props => [
        hash,
        from,
        to,
        amount,
        tokenSymbol,
        tokenAddress,
        type,
        status,
        timestamp,
        blockNumber,
        gasUsed,
        gasPrice,
        chainId,
      ];

  Transaction copyWith({
    String? hash,
    String? from,
    String? to,
    String? amount,
    String? tokenSymbol,
    String? tokenAddress,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? timestamp,
    String? blockNumber,
    String? gasUsed,
    String? gasPrice,
    String? chainId,
  }) {
    return Transaction(
      hash: hash ?? this.hash,
      from: from ?? this.from,
      to: to ?? this.to,
      amount: amount ?? this.amount,
      tokenSymbol: tokenSymbol ?? this.tokenSymbol,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      blockNumber: blockNumber ?? this.blockNumber,
      gasUsed: gasUsed ?? this.gasUsed,
      gasPrice: gasPrice ?? this.gasPrice,
      chainId: chainId ?? this.chainId,
    );
  }
}
