import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/shared/services/crypto_price_service.dart';
import 'package:nimbus/shared/presentation/pages/token_detail_screen.dart';
import 'package:nimbus/features/exchange/presentation/pages/swap_screen.dart';
import 'package:nimbus/features/buy/presentation/pages/buy_page.dart';
import 'package:nimbus/features/send/presentation/pages/send_page.dart';
import 'package:nimbus/features/receive/presentation/pages/receive_page.dart';
import 'package:nimbus/features/withdraw/presentation/pages/withdraw_page.dart';
import 'package:nimbus/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:nimbus/features/wallet/presentation/pages/wallet_settings_screen.dart';
import 'package:nimbus/features/buy/presentation/pages/purchase_status_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Consumer(
              builder: (context, ref, child) {
                final walletAddress = ref.watch(currentWalletAddressProvider);
                return Text(
                  walletAddress != null
                      ? '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}'
                      : 'Nimbus Wallet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.headset_mic, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Asset Balance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total asset balance',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final totalBalance = ref.watch(totalBalanceProvider);
                    return Text(
                      '\$${totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(Icons.add, 'Buy', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BuyPage()),
                  );
                }),
                _buildQuickAction(Icons.arrow_upward, 'Send', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SendPage()),
                  );
                }),
                _buildQuickAction(Icons.swap_horiz, 'Exchange', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SwapScreen()),
                  );
                }),
                _buildQuickAction(Icons.arrow_downward, 'Receive', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReceivePage()),
                  );
                }),
                _buildQuickAction(Icons.account_balance, 'Withdraw', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WithdrawPage()),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // My Assets Section
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My assets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement manage assets
                        },
                        child: const Text(
                          'Manage assets',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Assets List
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final cryptoPrices =
                          ref.watch(cryptoPricesRefreshProvider);

                      return cryptoPrices.when(
                        data: (prices) => ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: prices.length,
                          itemBuilder: (context, index) {
                            final crypto = prices[index];
                            return _buildAssetItem(context, crypto);
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6B35)),
                          ),
                        ),
                        error: (error, stackTrace) => Center(
                          child: Text(
                            'Error loading assets: $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Manage Assets Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement manage assets
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Manage assets',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(BuildContext context, CryptoPrice crypto) {
    final isPositive = crypto.change24h >= 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TokenDetailScreen(crypto: crypto),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Crypto Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  crypto.imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF333333),
                      child: const Icon(
                        Icons.currency_bitcoin,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Crypto Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${crypto.price.toStringAsFixed(2)} • ${isPositive ? '+' : ''}${crypto.change24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Balance Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${crypto.balanceValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  crypto.balance.toStringAsFixed(crypto.balance < 1 ? 4 : 2),
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _refreshData() {
    // Refresh crypto prices
    ref.invalidate(cryptoPricesRefreshProvider);

    // Refresh wallet data
    ref.invalidate(currentWalletAddressProvider);

    // Show refresh feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Purchase Status
            ListTile(
              leading:
                  const Icon(Icons.shopping_cart, color: Color(0xFFFF6B35)),
              title: const Text(
                'Purchase Status',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'View your crypto purchases',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseStatusScreen(),
                  ),
                );
              },
            ),

            // Wallet Settings
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text(
                'Wallet Settings',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Manage your wallet',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletSettingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
