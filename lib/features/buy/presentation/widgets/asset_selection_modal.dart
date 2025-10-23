import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/crypto_asset.dart';
import '../../../../shared/services/crypto_price_service.dart';

class AssetSelectionModal extends ConsumerWidget {
  final Function(CryptoAsset) onAssetSelected;
  final VoidCallback onClose;

  const AssetSelectionModal({
    super.key,
    required this.onAssetSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cryptoPrices = ref.watch(cryptoPricesProvider);

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(context, ref),

              // Search Bar
              _buildSearchBar(),

              // Category Filters
              _buildCategoryFilters(),

              // Asset List
              _buildAssetList(cryptoPrices),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF333333)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select asset',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => _refreshPrices(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter token name',
          hintStyle: TextStyle(color: Color(0xFF666666)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Color(0xFF666666)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryButton(Icons.menu, false),
          const SizedBox(width: 12),
          _buildCategoryButton(Icons.diamond, true),
          const SizedBox(width: 12),
          _buildCategoryButton(Icons.keyboard_arrow_down, false),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(IconData icon, bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF333333),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildAssetList(AsyncValue<List<CryptoPrice>> cryptoPrices) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: cryptoPrices.when(
        data: (prices) => ListView.builder(
          shrinkWrap: true,
          itemCount: prices.length,
          itemBuilder: (context, index) {
            final cryptoPrice = prices[index];
            final asset = _convertCryptoPriceToAsset(cryptoPrice);
            return _buildAssetItem(asset);
          },
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error loading prices',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Retry loading prices
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetItem(CryptoAsset asset) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.currency_bitcoin,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        asset.symbol,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        asset.name,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: Text(
        '\$${asset.price.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Color(0xFFFF6B35),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        onAssetSelected(asset);
        onClose();
      },
    );
  }

  CryptoAsset _convertCryptoPriceToAsset(CryptoPrice cryptoPrice) {
    return CryptoAsset(
      symbol: cryptoPrice.symbol,
      name: cryptoPrice.name,
      iconPath: cryptoPrice.imageUrl,
      category: 'cryptocurrency',
      price: cryptoPrice.price,
      balance: cryptoPrice.balance,
    );
  }

  void _refreshPrices(BuildContext context, WidgetRef ref) {
    // Refresh crypto prices
    ref.invalidate(cryptoPricesProvider);

    // Show refresh feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing prices...'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
