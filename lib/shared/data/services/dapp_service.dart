class DApp {
  final String name;
  final String logoUrl;
  final String description;
  final String category;
  final String website;
  final double? tvl;
  final double? volume24h;
  final double? priceChange24h;
  final bool isFavorite;
  final int color;

  DApp({
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.category,
    required this.website,
    this.tvl,
    this.volume24h,
    this.priceChange24h,
    this.isFavorite = false,
    required this.color,
  });

  DApp copyWith({
    String? name,
    String? logoUrl,
    String? description,
    String? category,
    String? website,
    double? tvl,
    double? volume24h,
    double? priceChange24h,
    bool? isFavorite,
    int? color,
  }) {
    return DApp(
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      website: website ?? this.website,
      tvl: tvl ?? this.tvl,
      volume24h: volume24h ?? this.volume24h,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      isFavorite: isFavorite ?? this.isFavorite,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'category': category,
      'website': website,
      'tvl': tvl,
      'volume24h': volume24h,
      'priceChange24h': priceChange24h,
      'isFavorite': isFavorite,
      'color': color,
    };
  }

  factory DApp.fromJson(Map<String, dynamic> json) {
    return DApp(
      name: json['name'],
      logoUrl: json['logoUrl'],
      description: json['description'],
      category: json['category'],
      website: json['website'],
      tvl: json['tvl']?.toDouble(),
      volume24h: json['volume24h']?.toDouble(),
      priceChange24h: json['priceChange24h']?.toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      color: json['color'],
    );
  }
}

class DAppService {
  // Static DApp data with real-time capabilities
  static final List<DApp> _dappGrid = [
    DApp(
      name: 'Jupiter',
      logoUrl: 'https://assets.coingecko.com/coins/images/10388/large/jup.png',
      description: 'Best price aggregator for Solana',
      category: 'DEX',
      website: 'https://jup.ag',
      tvl: 0,
      color: 0xFF4A90E2,
    ),
    DApp(
      name: 'Raydium',
      logoUrl:
          'https://assets.coingecko.com/coins/images/13928/large/PSigc4ie_400x400.jpg',
      description: 'Automated Market Maker on Solana',
      category: 'DEX',
      website: 'https://raydium.io',
      tvl: 0,
      color: 0xFF8B5CF6,
    ),
    DApp(
      name: 'Dedust',
      logoUrl:
          'https://assets.coingecko.com/coins/images/21162/large/dedust.png',
      description: 'Decentralized exchange on TON',
      category: 'DEX',
      website: 'https://dedust.io',
      tvl: 0,
      color: 0xFFF59E0B,
    ),
    DApp(
      name: 'Orca',
      logoUrl: 'https://assets.coingecko.com/coins/images/14195/large/orca.png',
      description: 'User-friendly Solana DEX',
      category: 'DEX',
      website: 'https://orca.so',
      tvl: 0,
      color: 0xFF6B7280,
    ),
    DApp(
      name: 'Tonstakers',
      logoUrl:
          'https://assets.coingecko.com/coins/images/17980/large/tonstakers.png',
      description: 'TON blockchain staking platform',
      category: 'Staking',
      website: 'https://tonstakers.com',
      tvl: 0,
      color: 0xFF000000,
    ),
    DApp(
      name: 'DeBank',
      logoUrl:
          'https://assets.coingecko.com/coins/images/18785/large/debank.png',
      description: 'DeFi portfolio tracker',
      category: 'Analytics',
      website: 'https://debank.com',
      tvl: 0,
      color: 0xFFEF4444,
    ),
    DApp(
      name: 'pump.fun',
      logoUrl:
          'https://assets.coingecko.com/coins/images/31957/large/pumpfun.png',
      description: 'Meme coin launchpad',
      category: 'Launchpad',
      website: 'https://pump.fun',
      tvl: 0,
      color: 0xFF10B981,
    ),
    DApp(
      name: 'Uniswap',
      logoUrl:
          'https://assets.coingecko.com/coins/images/12504/large/uniswap-uni.png',
      description: 'Leading Ethereum DEX',
      category: 'DEX',
      website: 'https://uniswap.org',
      tvl: 0,
      color: 0xFFEC4899,
    ),
  ];

  static final List<DApp> _protocols = [
    DApp(
      name: 'Lido',
      logoUrl:
          'https://assets.coingecko.com/coins/images/13573/large/Lido_DAO.png',
      description: 'Liquid staking for Ethereum, Solana, Polygon',
      category: 'Staking',
      website: 'https://lido.fi',
      tvl: 0,
      color: 0xFF4A90E2,
    ),
    DApp(
      name: 'Curve',
      logoUrl:
          'https://assets.coingecko.com/coins/images/12124/large/Curve.png',
      description: 'Stablecoin exchange and yield farming',
      category: 'DEX',
      website: 'https://curve.fi',
      tvl: 0,
      color: 0xFF8B5CF6,
    ),
    DApp(
      name: 'Marinade',
      logoUrl:
          'https://assets.coingecko.com/coins/images/17729/large/marinade.png',
      description: 'The easiest way to stake Solana',
      category: 'Staking',
      website: 'https://marinade.finance',
      tvl: 0,
      color: 0xFF14B8A6,
    ),
    DApp(
      name: 'Orca',
      logoUrl: 'https://assets.coingecko.com/coins/images/14195/large/orca.png',
      description: 'User-friendly Solana-Based DEX',
      category: 'DEX',
      website: 'https://orca.so',
      tvl: 0,
      color: 0xFFF59E0B,
    ),
    DApp(
      name: 'Scallop',
      logoUrl:
          'https://assets.coingecko.com/coins/images/24854/large/scallop.png',
      description: 'Lending protocol on Sui blockchain',
      category: 'Lending',
      website: 'https://scallop.io',
      tvl: 0,
      color: 0xFF8B5CF6,
    ),
    DApp(
      name: 'SushiSwap',
      logoUrl:
          'https://assets.coingecko.com/coins/images/12271/large/512x512_Logo_no_chop.png',
      description: 'Community-driven DEX',
      category: 'DEX',
      website: 'https://sushi.com',
      tvl: 0,
      color: 0xFFEF4444,
    ),
    DApp(
      name: 'autofarm',
      logoUrl:
          'https://assets.coingecko.com/coins/images/14056/large/autofarm.png',
      description: 'Yield farming optimizer',
      category: 'Yield',
      website: 'https://autofarm.network',
      tvl: 0,
      color: 0xFF3B82F6,
    ),
  ];

  // Get DApp grid data
  static List<DApp> getDAppGrid() => List.from(_dappGrid);

  // Get protocols data
  static List<DApp> getProtocols() => List.from(_protocols);

  // Get protocols by category
  static List<DApp> getProtocolsByCategory(String category) {
    return _protocols
        .where((protocol) =>
            protocol.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Search protocols
  static List<DApp> searchProtocols(String query) {
    if (query.isEmpty) return _protocols;
    return _protocols
        .where((protocol) =>
            protocol.name.toLowerCase().contains(query.toLowerCase()) ||
            protocol.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Toggle favorite
  static void toggleFavorite(String name) {
    for (int i = 0; i < _protocols.length; i++) {
      if (_protocols[i].name == name) {
        _protocols[i] =
            _protocols[i].copyWith(isFavorite: !_protocols[i].isFavorite);
        break;
      }
    }
  }

  // Get favorites
  static List<DApp> getFavorites() {
    return _protocols.where((protocol) => protocol.isFavorite).toList();
  }

  // Fetch real-time TVL data (mock for now)
  static Future<void> fetchRealTimeData() async {
    // In a real implementation, this would fetch from DeFiLlama API
    // For now, we'll simulate some data updates
    await Future.delayed(const Duration(seconds: 1));

    // Simulate TVL updates
    for (int i = 0; i < _protocols.length; i++) {
      final protocol = _protocols[i];
      final randomTvl = (1000000 +
              (i * 500000) +
              (DateTime.now().millisecondsSinceEpoch % 1000000))
          .toDouble();
      _protocols[i] = protocol.copyWith(tvl: randomTvl);
    }
  }

  // Get categories
  static List<String> getCategories() {
    return ['Favourites', 'Defi', 'Staking', 'Bridge', 'Lending', 'Dex'];
  }
}
