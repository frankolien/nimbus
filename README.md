# Nimbus - Web3 Crypto Wallet

A Flutter-based Web3 dApp for buying, sending, exchanging, and receiving cryptocurrencies with clean architecture.

## 🚀 Features

- **Real Blockchain Integration**: Connect to Ethereum and Solana networks
- **Crypto Trading**: Buy crypto with fiat through multiple payment providers
- **Wallet Management**: Secure custodial wallet with private key access
- **Real-time Prices**: Live crypto price updates from CoinGecko
- **DApp Discovery**: Browse and interact with Web3 applications
- **Staking**: Stake SOL with validators on Solana network

## 🔑 API Keys Setup

### Required API Keys

1. **Ankr RPC** (Free tier: 500 requests/minute)
   - Sign up at: https://www.ankr.com/rpc/
   - Get your free API key
   - Add to `lib/core/configs/api_keys.dart`

2. **CoinGecko** (Optional - for higher rate limits)
   - Sign up at: https://www.coingecko.com/en/api
   - Get your free API key
   - Add to `lib/core/configs/api_keys.dart`

### Optional API Keys

- **Alchemy**: For backup Ethereum RPC
- **Infura**: For backup Ethereum RPC  
- **QuickNode**: For backup RPC services
- **Moralis**: For advanced Web3 features

### Configuration

Update `lib/core/configs/api_keys.dart` with your actual API keys:

```dart
class ApiKeys {
  static const String ankrApiKey = 'your_actual_ankr_api_key';
  static const String coinGeckoApiKey = 'your_actual_coingecko_api_key';
  // ... other keys
}
```

## 🛠️ Installation

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Add your API keys to `lib/core/configs/api_keys.dart`
4. Run the app: `flutter run`

## 📱 Supported Networks

- **Ethereum Mainnet**: ETH, USDC, USDT
- **Solana Mainnet**: SOL
- **Payment Providers**: Banxa, MoonPay, Simplex, Coinbase, Binance

## 🔒 Security

- Private keys are encrypted and stored securely
- All API keys are kept in configuration files (not committed to git)
- Real blockchain integration for accurate balance tracking

## 📄 License

This project is licensed under the MIT License.

