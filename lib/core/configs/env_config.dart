import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get polygonRpcUrl => dotenv.env['POLYGON_RPC_URL'] ?? '';
  static String get mumbaiRpcUrl => dotenv.env['MUMBAI_RPC_URL'] ?? '';
  static String get alchemyApiKey => dotenv.env['ALCHEMY_API_KEY'] ?? '';
  static String get infuraApiKey => dotenv.env['INFURA_API_KEY'] ?? '';
  static String get zeroXApiKey => dotenv.env['ZEROX_API_KEY'] ?? '';
  static String get oneInchApiKey => dotenv.env['ONEINCH_API_KEY'] ?? '';
  static String get walletConnectProjectId => dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'Nimbus';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get defaultChainId => dotenv.env['DEFAULT_CHAIN_ID'] ?? '137';

  static bool get isProduction => dotenv.env['ENVIRONMENT'] == 'production';
  static bool get isDevelopment => dotenv.env['ENVIRONMENT'] == 'development';
}
