import '../entities/wallet.dart';
import '../../../../shared/entities/token.dart';

abstract class WalletRepository {
  Future<Wallet> connectWallet();
  Future<void> disconnectWallet();
  Future<Wallet> getCurrentWallet();
  Future<List<Token>> getTokenBalances(String walletAddress);
  Future<double> getNativeBalance(String walletAddress);
  Future<String> signTransaction(String transactionData);
  Future<String> sendTransaction(String transactionData);
  Future<bool> isWalletConnected();
}
