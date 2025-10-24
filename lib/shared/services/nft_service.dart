import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/entities/nft.dart';

class NFTService {
  // OpenSea API endpoints
  static const String _openseaApiBase = 'https://api.opensea.io/api/v1';
  static const String _openseaAssetsEndpoint = '$_openseaApiBase/assets';
  static const String _openseaCollectionsEndpoint =
      '$_openseaApiBase/collections';
  static const String _openseaEventsEndpoint = '$_openseaApiBase/events';

  // Popular NFT collections for trending
  static const List<String> _trendingCollections = [
    'boredapeyachtclub',
    'cryptopunks',
    'mutant-ape-yacht-club',
    'clonex',
    'azuki',
    'doodles-official',
    'cool-cats-nft',
    'world-of-women-nft',
    'veefriends',
    'chromie-squiggle-by-snowfro',
  ];

  /// Get trending NFTs from popular collections
  static Future<List<NFT>> getTrendingNFTs({int limit = 20}) async {
    try {
      print('🔍 Fetching trending NFTs...');

      final List<NFT> allNFTs = [];

      // Fetch from multiple popular collections
      for (final collectionSlug in _trendingCollections.take(3)) {
        try {
          final nfts = await _getNFTsFromCollection(collectionSlug, limit: 6);
          allNFTs.addAll(nfts);

          // Add small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          print('⚠️ Error fetching from collection $collectionSlug: $e');
          continue;
        }
      }

      // Shuffle and limit results
      allNFTs.shuffle();
      final result = allNFTs.take(limit).toList();

      // If no NFTs fetched, return mock data
      if (result.isEmpty) {
        print('⚠️ No NFTs fetched, returning mock data');
        return _getMockNFTs().take(limit).toList();
      }

      print('✅ Fetched ${result.length} trending NFTs');
      return result;
    } catch (e) {
      print('❌ Error fetching trending NFTs: $e');
      return _getMockNFTs();
    }
  }

  /// Get NFTs from a specific collection
  static Future<List<NFT>> _getNFTsFromCollection(String collectionSlug,
      {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_openseaAssetsEndpoint?collection=$collectionSlug&limit=$limit'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'NimbusWallet/1.0',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assets = data['assets'] as List<dynamic>? ?? [];

        return assets.map((asset) => _parseAssetToNFT(asset)).toList();
      } else {
        print('❌ OpenSea API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching NFTs from collection: $e');
      return [];
    }
  }

  /// Get recent NFT sales
  static Future<List<NFTSale>> getRecentSales({int limit = 10}) async {
    try {
      print('🔍 Fetching recent NFT sales...');

      final response = await http.get(
        Uri.parse('$_openseaEventsEndpoint?event_type=sale&limit=$limit'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'NimbusWallet/1.0',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['asset_events'] as List<dynamic>? ?? [];

        final sales = events.map((event) => _parseEventToSale(event)).toList();

        // If no sales fetched, return mock data
        if (sales.isEmpty) {
          print('⚠️ No sales fetched, returning mock data');
          return _getMockSales();
        }

        print('✅ Fetched ${sales.length} recent sales');
        return sales;
      } else {
        print('❌ OpenSea API error: ${response.statusCode}');
        return _getMockSales();
      }
    } catch (e) {
      print('❌ Error fetching recent sales: $e');
      return _getMockSales();
    }
  }

  /// Get popular NFT collections
  static Future<List<NFTCollection>> getPopularCollections(
      {int limit = 10}) async {
    try {
      print('🔍 Fetching popular NFT collections...');

      final List<NFTCollection> collections = [];

      for (final slug in _trendingCollections.take(limit)) {
        try {
          final collection = await _getCollectionDetails(slug);
          if (collection != null) {
            collections.add(collection);
          }

          // Add delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          print('⚠️ Error fetching collection $slug: $e');
          continue;
        }
      }

      // If no collections fetched, return mock data
      if (collections.isEmpty) {
        print('⚠️ No collections fetched, returning mock data');
        return _getMockCollections();
      }

      print('✅ Fetched ${collections.length} popular collections');
      return collections;
    } catch (e) {
      print('❌ Error fetching popular collections: $e');
      return _getMockCollections();
    }
  }

  /// Get collection details
  static Future<NFTCollection?> _getCollectionDetails(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$_openseaCollectionsEndpoint/$slug'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'NimbusWallet/1.0',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseCollectionData(data['collection']);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error fetching collection details: $e');
      return null;
    }
  }

  /// Parse OpenSea asset to NFT
  static NFT _parseAssetToNFT(Map<String, dynamic> asset) {
    final traits = <String>[];
    if (asset['traits'] != null) {
      traits.addAll((asset['traits'] as List)
          .map((trait) => '${trait['trait_type']}: ${trait['value']}'));
    }

    final imageUrl = asset['image_url'] ?? asset['image_preview_url'] ?? '';
    print('🖼️ NFT Image URL: $imageUrl for ${asset['name'] ?? 'Unnamed'}');

    return NFT(
      id: asset['id']?.toString() ?? '',
      name: asset['name'] ?? 'Unnamed',
      description: asset['description'] ?? '',
      imageUrl: imageUrl,
      collectionName: asset['collection']?['name'] ?? 'Unknown Collection',
      contractAddress: asset['asset_contract']?['address'] ?? '',
      tokenId: asset['token_id']?.toString() ?? '',
      floorPrice: _parsePrice(asset['collection']?['stats']?['floor_price']),
      lastSalePrice: _parsePrice(asset['last_sale']?['total_price']),
      lastSaleCurrency: asset['last_sale']?['payment_token']?['symbol'],
      lastSaleDate: _parseDate(asset['last_sale']?['event_timestamp']),
      owner: asset['owner']?['address'],
      traits: traits,
      rarityRank: asset['rarity_rank']?.toString(),
      isVerified: asset['collection']?['safelist_request_status'] == 'verified',
      externalLink: asset['external_link'],
      metadata: asset,
    );
  }

  /// Parse OpenSea event to sale
  static NFTSale _parseEventToSale(Map<String, dynamic> event) {
    final asset = event['asset'] ?? {};
    final paymentToken = event['payment_token'] ?? {};

    return NFTSale(
      id: event['id']?.toString() ?? '',
      nftId: asset['id']?.toString() ?? '',
      collectionName: asset['collection']?['name'] ?? 'Unknown',
      imageUrl: asset['image_url'] ?? '',
      price: _parsePrice(event['total_price']) ?? 0.0,
      currency: paymentToken['symbol'] ?? 'ETH',
      saleDate: _parseDate(event['event_timestamp']) ?? DateTime.now(),
      buyer: event['winner_account']?['address'] ?? '',
      seller: event['seller']?['address'] ?? '',
      transactionHash: event['transaction']?['transaction_hash'] ?? '',
    );
  }

  /// Parse collection data
  static NFTCollection _parseCollectionData(Map<String, dynamic> data) {
    final stats = data['stats'] ?? {};

    return NFTCollection(
      name: data['name'] ?? 'Unknown Collection',
      slug: data['slug'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      bannerImageUrl: data['banner_image_url'] ?? '',
      contractAddress: data['primary_asset_contracts']?[0]?['address'] ?? '',
      floorPrice: _parsePrice(stats['floor_price']),
      totalVolume: _parsePrice(stats['total_volume']),
      totalSupply: stats['total_supply'] ?? 0,
      ownersCount: stats['num_owners'] ?? 0,
      isVerified: data['safelist_request_status'] == 'verified',
      externalLink: data['external_url'],
      stats: stats,
    );
  }

  /// Parse price from various formats
  static double? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price);
    return null;
  }

  /// Parse date from timestamp
  static DateTime? _parseDate(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is String) return DateTime.tryParse(timestamp);
    if (timestamp is int)
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return null;
  }

  /// Mock data fallbacks
  static List<NFT> _getMockNFTs() {
    print('🎭 Using mock NFT data');
    return [
      NFT(
        id: '1',
        name: 'Bored Ape #1234',
        description: 'A unique Bored Ape from the Yacht Club',
        imageUrl: '',
        collectionName: 'Bored Ape Yacht Club',
        contractAddress: '0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D',
        tokenId: '1234',
        floorPrice: 15.5,
        lastSalePrice: 12.3,
        lastSaleCurrency: 'ETH',
        traits: ['Fur: Brown', 'Eyes: Blue', 'Hat: None'],
        isVerified: true,
      ),
      NFT(
        id: '2',
        name: 'CryptoPunk #5678',
        description: 'One of the original CryptoPunks',
        imageUrl: '',
        collectionName: 'CryptoPunks',
        contractAddress: '0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB',
        tokenId: '5678',
        floorPrice: 45.2,
        lastSalePrice: 38.7,
        lastSaleCurrency: 'ETH',
        traits: ['Type: Alien', 'Accessories: None'],
        isVerified: true,
      ),
      NFT(
        id: '3',
        name: 'Azuki #9999',
        description: 'A unique Azuki character',
        imageUrl: '',
        collectionName: 'Azuki',
        contractAddress: '0xED5AF388653567Af2F388E6224dC7C4b3241C544',
        tokenId: '9999',
        floorPrice: 8.5,
        lastSalePrice: 7.2,
        lastSaleCurrency: 'ETH',
        traits: ['Type: Human', 'Eyes: Blue'],
        isVerified: true,
      ),
    ];
  }

  static List<NFTSale> _getMockSales() {
    return [
      NFTSale(
        id: '1',
        nftId: '1',
        collectionName: 'Bored Ape Yacht Club',
        imageUrl:
            'https://i.seadn.io/gae/Ju9CkWtV-1Okvf0woDubU1iPgsR3xkJ6S1wOmTREe8u93LOcpl3aUsG5BOjcwfvzd4zqW8XwiThShx6rtfeCbS_tfuaFImYkv6gbmU',
        price: 12.3,
        currency: 'ETH',
        saleDate: DateTime.now().subtract(const Duration(hours: 2)),
        buyer: '0x1234...5678',
        seller: '0x8765...4321',
        transactionHash: '0xabcd1234...',
      ),
    ];
  }

  static List<NFTCollection> _getMockCollections() {
    return [
      NFTCollection(
        name: 'Bored Ape Yacht Club',
        slug: 'boredapeyachtclub',
        description: 'A collection of 10,000 Bored Ape NFTs',
        imageUrl:
            'https://i.seadn.io/gae/Ju9CkWtV-1Okvf0woDubU1iPgsR3xkJ6S1wOmTREe8u93LOcpl3aUsG5BOjcwfvzd4zqW8XwiThShx6rtfeCbS_tfuaFImYkv6gbmU',
        bannerImageUrl:
            'https://i.seadn.io/gae/Ju9CkWtV-1Okvf0woDubU1iPgsR3xkJ6S1wOmTREe8u93LOcpl3aUsG5BOjcwfvzd4zqW8XwiThShx6rtfeCbS_tfuaFImYkv6gbmU',
        contractAddress: '0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D',
        floorPrice: 15.5,
        totalVolume: 1250000.0,
        totalSupply: 10000,
        ownersCount: 6500,
        isVerified: true,
      ),
    ];
  }
}
