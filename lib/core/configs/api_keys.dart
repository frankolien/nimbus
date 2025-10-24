import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Keys Configuration for Nimbus Crypto Wallet
// All API keys are now loaded from environment variables for security

class ApiKeys {
  // Ankr RPC API Key (Free tier: 500 requests/minute)
  static String get ankrApiKey => dotenv.env['ANKR_API_KEY'] ?? '';

  // Alchemy API Key (NFT API and Ethereum RPC)
  static String get alchemyApiKey => dotenv.env['ALCHEMY_API_KEY'] ?? '';

  // CoinGecko API Key (Optional - for higher rate limits)
  static String get coinGeckoApiKey => dotenv.env['COINGECKO_API_KEY'] ?? '';

  // Infura API Key (Optional - for backup)
  static String get infuraApiKey => dotenv.env['INFURA_API_KEY'] ?? '';

  // QuickNode API Key (Optional - for backup)
  static String get quickNodeApiKey => dotenv.env['QUICKNODE_API_KEY'] ?? '';

  // Moralis API Key (Optional - for advanced features)
  static String get moralisApiKey => dotenv.env['MORALIS_API_KEY'] ?? '';

  // Firebase Configuration (if using Firebase)
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  // WalletConnect Project ID
  static String get walletConnectProjectId =>
      dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';

  // Payment Provider API Keys
  static String get moonPayPublicKey => dotenv.env['MOONPAY_PUBLIC_KEY'] ?? '';
  static String get moonPaySecretKey => dotenv.env['MOONPAY_SECRET_KEY'] ?? '';
  static String get banxaApiKey => dotenv.env['BANXA_API_KEY'] ?? '';
  static String get banxaSecretKey => dotenv.env['BANXA_SECRET_KEY'] ?? '';
  static String get simplexPartnerId => dotenv.env['SIMPLEX_PARTNER_ID'] ?? '';
  static String get simplexApiKey => dotenv.env['SIMPLEX_API_KEY'] ?? '';
  static String get coinbaseCommerceApiKey =>
      dotenv.env['COINBASE_COMMERCE_API_KEY'] ?? '';

  // Security Configuration
  static int get passwordHashRounds =>
      int.tryParse(dotenv.env['PASSWORD_HASH_ROUNDS'] ?? '12') ?? 12;
  static int get sessionTimeoutMinutes =>
      int.tryParse(dotenv.env['SESSION_TIMEOUT_MINUTES'] ?? '30') ?? 30;
  static int get maxLoginAttempts =>
      int.tryParse(dotenv.env['MAX_LOGIN_ATTEMPTS'] ?? '5') ?? 5;
}
