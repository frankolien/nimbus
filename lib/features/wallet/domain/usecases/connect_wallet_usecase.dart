import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class ConnectWalletUseCase {
  final WalletRepository _walletRepository;

  ConnectWalletUseCase(this._walletRepository);

  Future<Wallet> call() async {
    return await _walletRepository.connectWallet();
  }
}
