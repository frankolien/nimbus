import '../repositories/transaction_repository.dart';

class SendTransactionUseCase {
  final TransactionRepository _transactionRepository;

  SendTransactionUseCase(this._transactionRepository);

  Future<String> call({
    required String toAddress,
    required String tokenSymbol,
    required double amount,
  }) async {
    return await _transactionRepository.sendTransaction(
      toAddress: toAddress,
      tokenSymbol: tokenSymbol,
      amount: amount,
    );
  }
}
