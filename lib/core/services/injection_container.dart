import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../core/configs/env_config.dart';
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/exchange/data/datasources/swap_remote_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/exchange/data/repositories/swap_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/exchange/domain/repositories/swap_repository.dart';
import '../../features/wallet/domain/usecases/connect_wallet_usecase.dart';
import '../../features/wallet/domain/usecases/get_token_balances_usecase.dart';
import '../../features/wallet/domain/usecases/send_transaction_usecase.dart';
import '../../features/exchange/domain/usecases/swap_tokens_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Load environment variables
  await dotenv.load(fileName: '.env');

  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Web3Client(
        EnvConfig.polygonRpcUrl,
        http.Client(),
      ));

  // Data sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SwapRemoteDataSource>(
    () => SwapRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SwapRepository>(
    () => SwapRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => ConnectWalletUseCase(sl()));
  sl.registerLazySingleton(() => GetTokenBalancesUseCase(sl()));
  sl.registerLazySingleton(() => SendTransactionUseCase(sl()));
  sl.registerLazySingleton(() => SwapTokensUseCase(sl()));
}
