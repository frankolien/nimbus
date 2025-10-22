import '../../../../shared/entities/transaction.dart';

abstract class TransactionRepository {
  Future<String> sendTransaction({
    required String toAddress,
    required String tokenSymbol,
    required double amount,
  });

  Future<List<Transaction>> getTransactionHistory();
  Future<Transaction> getTransaction(String txHash);
}
