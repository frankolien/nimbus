import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/entities/nft.dart';
import '../../shared/services/nft_service.dart';

part 'nft_provider.g.dart';

@riverpod
class NFTNotifier extends _$NFTNotifier {
  @override
  Future<List<NFT>> build() async {
    print('🔄 NFTNotifier: Building NFT list...');
    final nfts = await NFTService.getTrendingNFTs();
    print('🔄 NFTNotifier: Got ${nfts.length} NFTs');
    return nfts;
  }

  Future<void> refreshTrendingNFTs() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => NFTService.getTrendingNFTs());
  }

  Future<void> loadMoreNFTs() async {
    if (state.hasValue) {
      final currentNFTs = state.value!;
      final newNFTs = await NFTService.getTrendingNFTs(limit: 10);

      // Avoid duplicates
      final existingIds = currentNFTs.map((nft) => nft.id).toSet();
      final uniqueNewNFTs =
          newNFTs.where((nft) => !existingIds.contains(nft.id)).toList();

      state = AsyncValue.data([...currentNFTs, ...uniqueNewNFTs]);
    }
  }
}

@riverpod
class NFTSalesNotifier extends _$NFTSalesNotifier {
  @override
  Future<List<NFTSale>> build() async {
    return await NFTService.getRecentSales();
  }

  Future<void> refreshRecentSales() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => NFTService.getRecentSales());
  }
}

@riverpod
class NFTCollectionsNotifier extends _$NFTCollectionsNotifier {
  @override
  Future<List<NFTCollection>> build() async {
    return await NFTService.getPopularCollections();
  }

  Future<void> refreshCollections() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => NFTService.getPopularCollections());
  }
}

// Provider for NFT categories/tabs
@riverpod
class NFTCategoryNotifier extends _$NFTCategoryNotifier {
  @override
  String build() => 'trending';

  void setCategory(String category) {
    state = category;
  }
}

// Provider for search functionality
@riverpod
class NFTSearchNotifier extends _$NFTSearchNotifier {
  @override
  String build() => '';

  void setSearchQuery(String query) {
    state = query;
  }

  void clearSearch() {
    state = '';
  }
}

// Provider for NFT stats
@riverpod
Future<Map<String, dynamic>> nftStats(NftStatsRef ref) async {
  try {
    final trendingNFTs = await ref.watch(nFTNotifierProvider.future);
    final recentSales = await ref.watch(nFTSalesNotifierProvider.future);
    final collections = await ref.watch(nFTCollectionsNotifierProvider.future);

    // Calculate stats
    final totalVolume =
        recentSales.fold<double>(0.0, (sum, sale) => sum + sale.price);
    final averagePrice =
        recentSales.isNotEmpty ? totalVolume / recentSales.length : 0.0;
    final totalCollections = collections.length;
    final verifiedCollections = collections.where((c) => c.isVerified).length;

    return {
      'totalVolume': totalVolume,
      'averagePrice': averagePrice,
      'totalCollections': totalCollections,
      'verifiedCollections': verifiedCollections,
      'totalSales': recentSales.length,
      'totalNFTs': trendingNFTs.length,
    };
  } catch (e) {
    return {
      'totalVolume': 0.0,
      'averagePrice': 0.0,
      'totalCollections': 0,
      'verifiedCollections': 0,
      'totalSales': 0,
      'totalNFTs': 0,
    };
  }
}
