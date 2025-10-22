import '../../domain/entities/wallet.dart';
import '../../../../shared/entities/token.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/wallet_remote_datasource.dart';
import '../models/wallet_model.dart';
import '../../../../shared/models/token_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<Wallet> connectWallet() async {
    try {
      final address = await _remoteDataSource.connectWallet();
      return WalletModel(
        address: address,
        isConnected: true,
      );
    } catch (e) {
      throw WalletConnectionFailure('Failed to connect wallet: $e');
    }
  }

  @override
  Future<void> disconnectWallet() async {
    try {
      await _remoteDataSource.disconnectWallet();
    } catch (e) {
      throw WalletConnectionFailure('Failed to disconnect wallet: $e');
    }
  }

  @override
  Future<Wallet> getCurrentWallet() async {
    try {
      final address = await _remoteDataSource.getWalletAddress();
      final isConnected = await _remoteDataSource.isWalletConnected();
      return WalletModel(
        address: address,
        isConnected: isConnected,
      );
    } catch (e) {
      throw WalletConnectionFailure('Failed to get current wallet: $e');
    }
  }

  @override
  Future<List<Token>> getTokenBalances(String walletAddress) async {
    try {
      final balances = await _remoteDataSource.getTokenBalances(walletAddress);
      return balances.map((balance) => TokenModel.fromJson(balance)).toList();
    } catch (e) {
      throw NetworkFailure('Failed to get token balances: $e');
    }
  }

  @override
  Future<double> getNativeBalance(String walletAddress) async {
    try {
      return await _remoteDataSource.getNativeBalance(walletAddress);
    } catch (e) {
      throw NetworkFailure('Failed to get native balance: $e');
    }
  }

  @override
  Future<String> signTransaction(String transactionData) async {
    try {
      return await _remoteDataSource.signTransaction(transactionData);
    } catch (e) {
      throw TransactionFailure('Failed to sign transaction: $e');
    }
  }

  @override
  Future<String> sendTransaction(String transactionData) async {
    try {
      return await _remoteDataSource.sendTransaction(transactionData);
    } catch (e) {
      throw TransactionFailure('Failed to send transaction: $e');
    }
  }

  @override
  Future<bool> isWalletConnected() async {
    try {
      return await _remoteDataSource.isWalletConnected();
    } catch (e) {
      throw WalletConnectionFailure('Failed to check wallet connection: $e');
    }
  }
}
