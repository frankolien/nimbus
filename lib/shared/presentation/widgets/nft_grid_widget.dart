import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../entities/nft.dart';
import '../../providers/nft_provider.dart';
import '../../services/nft_service.dart';
import '../../../features/wallet/presentation/providers/wallet_provider.dart';
import '../pages/nft_purchase_receipt_screen.dart';
import '../pages/nft_bid_confirmation_screen.dart';

class NFTGridWidget extends ConsumerWidget {
  final String title;
  final String category;
  final bool showStats;
  final VoidCallback? onViewAll;

  const NFTGridWidget({
    super.key,
    required this.title,
    required this.category,
    this.showStats = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nftAsync = ref.watch(nFTNotifierProvider);
    final statsAsync = showStats ? ref.watch(nftStatsProvider) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (showStats && statsAsync?.hasValue == true)
                    Text(
                      '${statsAsync?.value?['totalNFTs']} NFTs • ${statsAsync?.value?['totalCollections']} Collections',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // NFT Grid
        nftAsync.when(
          data: (nfts) => _buildNFTGrid(context, nfts),
          loading: () => _buildLoadingGrid(),
          error: (error, stack) => _buildErrorWidget(error),
        ),
      ],
    );
  }

  Widget _buildNFTGrid(BuildContext context, List<NFT> nfts) {
    if (nfts.isEmpty) {
      return _buildEmptyWidget();
    }

    print('🖼️ Building NFT grid with ${nfts.length} NFTs');
    for (final nft in nfts) {
      print('🖼️ NFT: ${nft.name} - Image URL: ${nft.imageUrl}');
    }

    return SizedBox(
      height: 240,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: nfts.map((nft) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildNFTCard(context, nft),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNFTCard(BuildContext context, NFT nft) {
    return GestureDetector(
      onTap: () => _showNFTDetails(context, nft),
      child: Container(
        width: 160,
        constraints: const BoxConstraints(
          minHeight: 200,
          maxHeight: 240,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // NFT Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 140,
                width: double.infinity,
                color: Colors.grey[800],
                child: nft.imageUrl.isNotEmpty
                    ? Image.network(
                        nft.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ NFT Image Error: ${nft.name} - $error');
                          print('❌ Image URL: ${nft.imageUrl}');
                          return Container(
                            color: Colors.grey[800],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 50,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nft.name,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nft.collectionName,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF6B35),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nft.name,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nft.collectionName,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // NFT Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Collection Name
                    Text(
                      nft.collectionName,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // NFT Name
                    Text(
                      nft.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Price
                    if (nft.floorPrice != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_exchange,
                            size: 12,
                            color: Color(0xFFFF6B35),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${nft.floorPrice!.toStringAsFixed(1)} ETH',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'No floor price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SizedBox(
      height: 240,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load NFTs',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error.toString(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              'No NFTs found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNFTDetails(BuildContext context, NFT nft) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NFTDetailModal(nft: nft),
    );
  }
}

class NFTDetailModal extends ConsumerWidget {
  final NFT nft;

  const NFTDetailModal({super.key, required this.nft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NFT Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: nft.imageUrl.isNotEmpty
                          ? Image.network(
                              nft.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 60,
                                  ),
                                );
                              },
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 60,
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NFT Info
                  Text(
                    nft.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    nft.collectionName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (nft.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nft.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Price Info
                  if (nft.floorPrice != null || nft.lastSalePrice != null) ...[
                    const Text(
                      'Price Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (nft.floorPrice != null)
                      _buildPriceRow('Floor Price',
                          '${nft.floorPrice!.toStringAsFixed(2)} ETH'),
                    if (nft.lastSalePrice != null)
                      _buildPriceRow('Last Sale',
                          '${nft.lastSalePrice!.toStringAsFixed(2)} ${nft.lastSaleCurrency ?? 'ETH'}'),
                  ],

                  const SizedBox(height: 20),

                  // Traits
                  if (nft.traits.isNotEmpty) ...[
                    const Text(
                      'Traits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: nft.traits.map((trait) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            trait,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Purchase Info and Actions
                  _buildPurchaseSection(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection(BuildContext context, WidgetRef ref) {
    final purchaseInfoAsync =
        ref.watch(nftPurchaseInfoProvider(nft.contractAddress, nft.tokenId));
    final walletState = ref.watch(walletStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purchase Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        purchaseInfoAsync.when(
          data: (purchaseInfo) =>
              _buildPurchaseInfo(context, ref, purchaseInfo, walletState),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
          ),
          error: (error, stack) => Text(
            'Error loading purchase info: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseInfo(BuildContext context, WidgetRef ref,
      Map<String, dynamic> purchaseInfo, AsyncValue walletState) {
    final buyNowPrice = purchaseInfo['buyNowPrice'] as double?;
    final bidPrice = purchaseInfo['bidPrice'] as double?;
    final gasEstimate = purchaseInfo['gasEstimate'] as double?;
    final marketplace = purchaseInfo['marketplace'] as String?;

    return Column(
      children: [
        // Price Information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3A3C)),
          ),
          child: Column(
            children: [
              if (buyNowPrice != null)
                _buildPriceRow(
                    'Buy Now', '${buyNowPrice.toStringAsFixed(3)} ETH'),
              if (bidPrice != null)
                _buildPriceRow(
                    'Current Bid', '${bidPrice.toStringAsFixed(3)} ETH'),
              if (gasEstimate != null)
                _buildPriceRow(
                    'Gas Fee', '${gasEstimate.toStringAsFixed(3)} ETH'),
              if (marketplace != null)
                _buildPriceRow('Marketplace', marketplace),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: walletState.hasValue
                    ? () => _showBuyDialog(context, ref, buyNowPrice ?? 0.5)
                    : null,
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: const Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: walletState.hasValue
                    ? () => _showBidDialog(context, ref, bidPrice ?? 0.4)
                    : null,
                icon: const Icon(Icons.gavel, size: 18),
                label: const Text('Place Bid'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B35),
                  side: const BorderSide(color: Color(0xFFFF6B35)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (!walletState.hasValue) ...[
          const SizedBox(height: 12),
          const Text(
            'Connect your wallet to purchase NFTs',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  void _showBuyDialog(BuildContext context, WidgetRef ref, double price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Buy NFT',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to buy this NFT for ${price.toStringAsFixed(3)} ETH?',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Cost: ${(price + 0.01).toStringAsFixed(3)} ETH (including gas)',
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _executePurchase(context, ref, price),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Purchase'),
          ),
        ],
      ),
    );
  }

  void _showBidDialog(BuildContext context, WidgetRef ref, double currentBid) {
    final bidController =
        TextEditingController(text: (currentBid + 0.05).toStringAsFixed(3));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Place Bid',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Floor:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${currentBid.toStringAsFixed(3)} ETH',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bidController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Your bid (ETH)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6B35)),
                ),
                helperText: 'Bid must be higher than current floor price',
                helperStyle: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bids expire in 7 days. You can increase your bid anytime.',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You have 0.0 ETH. This is a demo - bids will be simulated.',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final bidAmount = double.tryParse(bidController.text);
              if (bidAmount != null && bidAmount > currentBid) {
                _executeBid(context, ref, bidAmount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Bid must be higher than current floor price'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('Place Demo Bid'),
          ),
        ],
      ),
    );
  }

  Future<void> _executePurchase(
      BuildContext context, WidgetRef ref, double price) async {
    print(
        '🛒 Starting purchase execution for ${nft.name} - ${price.toStringAsFixed(3)} ETH');

    Navigator.pop(context); // Close dialog

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      ),
    );

    try {
      print('🔍 Checking wallet state...');
      final walletState = ref.read(walletStateProvider);

      // If wallet is not connected, try to connect it first
      if (!walletState.hasValue || walletState.value == null) {
        print('🔄 Wallet not connected, attempting to connect...');
        final walletStateNotifier = ref.read(walletStateProvider.notifier);
        await walletStateNotifier.connectWallet();

        // Re-read the wallet state after connection attempt
        final updatedWalletState = ref.read(walletStateProvider);
        if (!updatedWalletState.hasValue || updatedWalletState.value == null) {
          print('❌ Failed to connect wallet');
          throw Exception('Failed to connect wallet');
        }
        final wallet = updatedWalletState.value!;
        print('✅ Wallet connected: ${wallet.address}');
      } else {
        final wallet = walletState.value!;
        print('✅ Wallet already connected: ${wallet.address}');
      }

      // Get the final wallet state
      final finalWalletState = ref.read(walletStateProvider);
      final wallet = finalWalletState.value!;

      print('💳 Calling NFTService.purchaseNFT...');
      // For now, use a mock private key to avoid the custodial service complexity
      // In a real app, this would come from secure storage
      final mockPrivateKey =
          '0x1b9a64fa8c4c8b8e8f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e';

      // Use a mock wallet address for testing
      final mockWalletAddress = '0xd3b457c239a5594860cfa9c3a376890b3e4724a4';

      print('🛒 Using mock wallet address: $mockWalletAddress');

      final result = await NFTService.purchaseNFT(
        contractAddress: nft.contractAddress,
        tokenId: nft.tokenId,
        price: price,
        buyerAddress: mockWalletAddress,
        privateKey: mockPrivateKey,
      );

      print('✅ Purchase result: $result');

      if (context.mounted) Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        print('🎉 Purchase successful, navigating to receipt...');
        HapticFeedback.lightImpact();
        if (context.mounted) {
          // Navigate to purchase receipt screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NFTPurchaseReceiptScreen(
                nft: nft,
                purchaseResult: result,
              ),
            ),
          );
        }
      } else {
        print('❌ Purchase failed: ${result['error']}');
        throw Exception(result['error'] ?? 'Purchase failed');
      }
    } catch (e) {
      print('❌ Purchase execution error: $e');
      if (context.mounted) Navigator.pop(context); // Close loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _executeBid(
      BuildContext context, WidgetRef ref, double bidAmount) async {
    print(
        '🎯 Starting bid execution for ${nft.name} - ${bidAmount.toStringAsFixed(3)} ETH');

    Navigator.pop(context); // Close dialog

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      ),
    );

    try {
      print('🔍 Checking wallet state...');
      final walletState = ref.read(walletStateProvider);
      if (!walletState.hasValue) {
        print('❌ Wallet not connected');
        throw Exception('Wallet not connected');
      }

      print('✅ Wallet connected: ${walletState.value!.address}');
      final wallet = walletState.value!;

      print('🎯 Placing bid...');
      // For now, use a mock private key to avoid the custodial service complexity
      // In a real app, this would come from secure storage
      final mockPrivateKey =
          '0x1b9a64fa8c4c8b8e8f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e';

      final result = await NFTService.placeBid(
        contractAddress: nft.contractAddress,
        tokenId: nft.tokenId,
        bidAmount: bidAmount,
        bidderAddress: wallet.address,
        privateKey: mockPrivateKey,
        expirationTime: const Duration(days: 7),
      );

      print('✅ Bid result: $result');

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result['success'] == true) {
        HapticFeedback.lightImpact();
        if (context.mounted) {
          // Navigate to bid confirmation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NFTBidConfirmationScreen(
                nft: nft,
                bidResult: result,
              ),
            ),
          );
        }
      } else {
        throw Exception(result['error'] ?? 'Bid failed');
      }
    } catch (e) {
      print('❌ Bid execution error: $e');
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
