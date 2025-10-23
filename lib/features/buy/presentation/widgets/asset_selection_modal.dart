import 'package:flutter/material.dart';

import '../../domain/entities/crypto_asset.dart';

class AssetSelectionModal extends StatelessWidget {
  final Function(CryptoAsset) onAssetSelected;
  final VoidCallback onClose;

  const AssetSelectionModal({
    super.key,
    required this.onAssetSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),

              // Search Bar
              _buildSearchBar(),

              // Category Filters
              _buildCategoryFilters(),

              // Asset List
              _buildAssetList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
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

  Widget _buildAssetList() {
    final assets = _getMockAssets();

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return _buildAssetItem(asset);
        },
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
      onTap: () {
        onAssetSelected(asset);
        onClose();
      },
    );
  }

  List<CryptoAsset> _getMockAssets() {
    return [
      const CryptoAsset(
        symbol: 'SOL',
        name: 'Solana',
        iconPath: '',
        category: 'Solana',
        price: 100.0,
        balance: 0.0,
      ),
      const CryptoAsset(
        symbol: 'USDT',
        name: 'Tether',
        iconPath: '',
        category: 'Stablecoin',
        price: 1.0,
        balance: 0.0,
      ),
      const CryptoAsset(
        symbol: 'USDC',
        name: 'USD Coin',
        iconPath: '',
        category: 'Stablecoin',
        price: 1.0,
        balance: 0.0,
      ),
      const CryptoAsset(
        symbol: 'LINK',
        name: 'Chainlink',
        iconPath: '',
        category: 'DeFi',
        price: 15.0,
        balance: 0.0,
      ),
      const CryptoAsset(
        symbol: 'PYUSD',
        name: 'Paypal USD',
        iconPath: '',
        category: 'Stablecoin',
        price: 1.0,
        balance: 0.0,
      ),
      const CryptoAsset(
        symbol: 'JUP',
        name: 'Jupiter',
        iconPath: '',
        category: 'DeFi',
        price: 0.5,
        balance: 0.0,
      ),
      const CryptoAsset(
        symbol: 'RAY',
        name: 'Raydium',
        iconPath: '',
        category: 'DeFi',
        price: 2.0,
        balance: 0.0,
      ),
    ];
  }
}
