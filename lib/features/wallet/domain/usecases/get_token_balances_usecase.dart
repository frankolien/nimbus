import '../../../../shared/entities/token.dart';
import '../repositories/wallet_repository.dart';

class GetTokenBalancesUseCase {
  final WalletRepository _walletRepository;

  GetTokenBalancesUseCase(this._walletRepository);

  Future<List<Token>> call(String walletAddress) async {
    return await _walletRepository.getTokenBalances(walletAddress);
  }
}
