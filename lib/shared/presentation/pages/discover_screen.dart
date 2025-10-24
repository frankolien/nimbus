import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:nimbus/shared/data/services/dapp_service.dart';
import 'package:nimbus/shared/presentation/providers/discover_provider.dart';
import 'package:nimbus/shared/presentation/widgets/nft_grid_widget.dart';
import 'package:nimbus/shared/providers/nft_provider.dart';
import 'package:nimbus/shared/entities/nft.dart';
import 'package:nimbus/shared/presentation/pages/nft_purchase_test_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Start auto-refresh after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoRefresh();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        ref.read(discoverProvider.notifier).refreshData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getAssetPath(String dappName) {
    String assetName = dappName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('.', '_')
        .replaceAll('-', '_');
    return 'assets/images/${assetName}.png';
  }

  @override
  Widget build(BuildContext context) {
    try {
      final discoverState = ref.watch(discoverProvider);
      final dappGrid = ref.watch(dappGridProvider);
      final categories = ref.watch(categoriesProvider);
      final searchQuery = ref.watch(nFTSearchNotifierProvider);

      return Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NFTPurchaseTestScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFFFF6B35),
          child: const Icon(Icons.bug_report, color: Colors.white),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 16),

                // Show search results if searching
                if (searchQuery.isNotEmpty) ...[
                  _buildSearchResults(searchQuery),
                ] else ...[
                  // DApp Grid
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF3A3A3C),
                          width: 1,
                        ),
                      ),
                      child: _buildDAppGrid(dappGrid),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NFT Section
                  NFTGridWidget(
                    title: 'Trending NFTs',
                    category: 'trending',
                    showStats: true,
                    onViewAll: () => _showAllNFTs(),
                  ),
                  const SizedBox(height: 16),

                  // Navigation Tabs
                  _buildNavigationTabs(categories, discoverState.selectedTab),
                  const SizedBox(height: 12),

                  // Content based on selected tab
                  _buildTabContent(discoverState),
                ],
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error in DiscoverScreen build: $e');
      return Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: const Center(
          child: Text(
            'Error loading Discover screen',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildSearchResults(String query) {
    final searchResultsAsync = ref.watch(nftSearchResultsProvider(query));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Results Header
          Row(
            children: [
              Text(
                'Search Results for "$query"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(discoverProvider.notifier).clearSearch();
                  ref.read(nFTSearchNotifierProvider.notifier).clearSearch();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Color(0xFFFF6B35)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Results
          searchResultsAsync.when(
            data: (nfts) {
              if (nfts.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        color: Colors.grey[600],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No NFTs found for "$query"',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: nfts.length,
                itemBuilder: (context, index) {
                  final nft = nfts[index];
                  return GestureDetector(
                    onTap: () => _showNFTDetail(context, nft),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3A3A3C)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NFT Image
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[800],
                                child: nft.imageUrl.isNotEmpty
                                    ? Image.network(
                                        nft.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[800],
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image,
                                                  color: Colors.grey[400],
                                                  size: 30,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  nft.name,
                                                  style: TextStyle(
                                                    color: Colors.grey[300],
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              color: Colors.grey[400],
                                              size: 30,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              nft.name,
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          // NFT Info
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nft.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    nft.collectionName,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  if (nft.floorPrice != null)
                                    Text(
                                      '${nft.floorPrice!.toStringAsFixed(2)} ETH',
                                      style: const TextStyle(
                                        color: Color(0xFFFF6B35),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
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
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error searching NFTs: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNFTDetail(BuildContext context, NFT nft) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NFTDetailModal(nft: nft),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'search or type a url',
            hintStyle: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF8E8E93),
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(discoverProvider.notifier).clearSearch();
                      ref
                          .read(nFTSearchNotifierProvider.notifier)
                          .clearSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            ref.read(discoverProvider.notifier).updateSearchQuery(value);
            ref.read(nFTSearchNotifierProvider.notifier).setSearchQuery(value);
          },
        ),
      ),
    );
  }

  Widget _buildDAppGrid(List<DApp> dappGrid) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: dappGrid.length,
      itemBuilder: (context, index) {
        final dapp = dappGrid[index];
        return GestureDetector(
          onTap: () => _openDApp(dapp),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(dapp.color),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    dapp.logoUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        _getAssetPath(dapp.name),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(dapp.color),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.apps,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dapp.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationTabs(List<String> categories, String selectedTab) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((tab) {
            final isSelected = tab == selectedTab;
            return GestureDetector(
              onTap: () {
                ref.read(discoverProvider.notifier).selectTab(tab);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                child: Column(
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF8E8E93),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 2,
                        width: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(1)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(DiscoverState state) {
    switch (state.selectedTab.toLowerCase()) {
      case 'nfts':
        return _buildNFTContent();
      case 'protocols':
      default:
        return _buildProtocolsList(state);
    }
  }

  Widget _buildNFTContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Sales
          NFTGridWidget(
            title: 'Recent Sales',
            category: 'sales',
            showStats: false,
          ),
          const SizedBox(height: 24),

          // Popular Collections
          NFTGridWidget(
            title: 'Popular Collections',
            category: 'collections',
            showStats: false,
          ),
          const SizedBox(height: 24),

          // NFT Stats
          _buildNFTStats(),
        ],
      ),
    );
  }

  Widget _buildNFTStats() {
    final statsAsync = ref.watch(nftStatsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NFT Market Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => _buildStatsGrid(stats),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            ),
            error: (error, stack) => Text(
              'Error loading stats: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth > 300 ? 2.5 : 2.0,
          children: [
            _buildStatCard('Total Volume',
                '${stats['totalVolume']?.toStringAsFixed(1) ?? '0.0'} ETH'),
            _buildStatCard('Avg Price',
                '${stats['averagePrice']?.toStringAsFixed(2) ?? '0.00'} ETH'),
            _buildStatCard('Collections', '${stats['totalCollections'] ?? 0}'),
            _buildStatCard('Recent Sales', '${stats['totalSales'] ?? 0}'),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAllNFTs() {
    // Navigate to full NFT screen or show modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAllNFTsModal(),
    );
  }

  Widget _buildAllNFTsModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All NFTs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // NFT Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NFTGridWidget(
                title: '',
                category: 'all',
                showStats: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolsList(DiscoverState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (state.filteredProtocols.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey[600],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No results found for "${state.searchQuery}"'
                  : 'No protocols in this category',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: state.filteredProtocols.map((protocol) {
          return _buildProtocolItem(protocol);
        }).toList(),
      ),
    );
  }

  Widget _buildProtocolItem(DApp protocol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openProtocol(protocol),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3A3A3C),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(protocol.color),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      protocol.logoUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          _getAssetPath(protocol.name),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(protocol.color),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.apps,
                                color: Colors.white,
                                size: 20,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              protocol.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (protocol.tvl != null && protocol.tvl! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3C),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '\$${_formatNumber(protocol.tvl!)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        protocol.description,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(protocol.color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              protocol.category,
                              style: TextStyle(
                                color: Color(protocol.color),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (protocol.priceChange24h != null)
                            Row(
                              children: [
                                Icon(
                                  protocol.priceChange24h! >= 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: protocol.priceChange24h! >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${protocol.priceChange24h!.abs().toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: protocol.priceChange24h! >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(discoverProvider.notifier)
                        .toggleFavorite(protocol.name);
                    HapticFeedback.lightImpact();
                  },
                  child: Icon(
                    protocol.isFavorite ? Icons.star : Icons.star_border,
                    color: protocol.isFavorite
                        ? Colors.amber
                        : const Color(0xFF8E8E93),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  void _openDApp(DApp dapp) async {
    try {
      HapticFeedback.lightImpact();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );

      // Launch the DApp URL
      final Uri url = Uri.parse(dapp.website);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${dapp.name} in browser...'),
              backgroundColor: const Color(0xFF2C2C2E),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open ${dapp.name}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening ${dapp.name}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openProtocol(DApp protocol) {
    // In a real app, this would navigate to protocol details
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(protocol.color),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  protocol.logoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.apps,
                      color: Colors.white,
                      size: 40,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              protocol.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              protocol.description,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _openDApp(protocol);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(protocol.color),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Open DApp'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF3A3A3C)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
