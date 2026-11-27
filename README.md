# Nimbus - Web3 Crypto Wallet

A Flutter-based Web3 dApp for buying, sending, exchanging, and receiving cryptocurrencies with clean architecture.

## Wallet: built on Xend

The wallet runs on the [Xend SDK](https://pub.dev/packages/xend). Nimbus holds no keys and
does no signing itself:

- **Create** is one tap. The key is generated in the Secure Enclave, and its seed is backed
  up to iCloud Keychain, so a new iPhone recovers the wallet silently.
- **Send** goes through `wallet.send()`. Xend checks the transaction against what the review
  sheet showed before Face ID signs it, and fees are sponsored (users need no SOL).
- **Balance and activity** come from `wallet.balance()` and `wallet.history()`.
- **Recovery phrase** export is in Settings, behind Face ID.

Solana devnet only for now; other chains show "coming soon".

### Run it

1. Start the Xend backend (see the Xend repo): `cargo run --bin xend-backend`, with
   `XEND_PAYMASTER_SECRET` set for gasless sends.
2. Set `XEND_BACKEND_URL` in `.env` (default `http://localhost:8080`; a device needs your
   machine's LAN IP).
3. `flutter run` on an iOS simulator or device.

End-to-end test through the real UI (create, fund, send, confirm):

```sh
flutter test integration_test/xend_flow_test.dart -d <simulator-id>
# when it prints NIMBUS_ADDR=..., fund it:
solana transfer --url devnet --allow-unfunded-recipient <address> 0.05
```

##  Features

- **Real Blockchain Integration**: Connect to Ethereum and Solana networks
- **Crypto Trading**: Buy crypto with fiat through multiple payment providers
- **Wallet**: self-custodial, Secure Enclave keys via Xend, Face ID per transaction
- **Real-time Prices**: Live crypto price updates from CoinGecko
- **DApp Discovery**: Browse and interact with Web3 applications
- **Staking**: Stake SOL with validators on Solana network

##  API Keys Setup

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

## Supported Networks

- **Solana Devnet**: SOL (via Xend)
- **EVM chains**: coming soon
- **Payment Providers**: Banxa, MoonPay, Simplex, Coinbase, Binance

##  Security

- Keys never leave the Secure Enclave; Nimbus never sees a private key or phrase unless the user exports it
- All API keys are kept in configuration files (not committed to git)
- Real blockchain integration for accurate balance tracking

##  License

This project is licensed under the MIT License.

