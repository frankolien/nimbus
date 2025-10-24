import 'package:equatable/equatable.dart';

class NFT extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String collectionName;
  final String contractAddress;
  final String tokenId;
  final double? floorPrice;
  final double? lastSalePrice;
  final String? lastSaleCurrency;
  final DateTime? lastSaleDate;
  final String? owner;
  final List<String> traits;
  final String? rarityRank;
  final bool isVerified;
  final String? externalLink;
  final Map<String, dynamic> metadata;

  const NFT({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.collectionName,
    required this.contractAddress,
    required this.tokenId,
    this.floorPrice,
    this.lastSalePrice,
    this.lastSaleCurrency,
    this.lastSaleDate,
    this.owner,
    this.traits = const [],
    this.rarityRank,
    this.isVerified = false,
    this.externalLink,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        collectionName,
        contractAddress,
        tokenId,
        floorPrice,
        lastSalePrice,
        lastSaleCurrency,
        lastSaleDate,
        owner,
        traits,
        rarityRank,
        isVerified,
        externalLink,
        metadata,
      ];

  NFT copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? collectionName,
    String? contractAddress,
    String? tokenId,
    double? floorPrice,
    double? lastSalePrice,
    String? lastSaleCurrency,
    DateTime? lastSaleDate,
    String? owner,
    List<String>? traits,
    String? rarityRank,
    bool? isVerified,
    String? externalLink,
    Map<String, dynamic>? metadata,
  }) {
    return NFT(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      collectionName: collectionName ?? this.collectionName,
      contractAddress: contractAddress ?? this.contractAddress,
      tokenId: tokenId ?? this.tokenId,
      floorPrice: floorPrice ?? this.floorPrice,
      lastSalePrice: lastSalePrice ?? this.lastSalePrice,
      lastSaleCurrency: lastSaleCurrency ?? this.lastSaleCurrency,
      lastSaleDate: lastSaleDate ?? this.lastSaleDate,
      owner: owner ?? this.owner,
      traits: traits ?? this.traits,
      rarityRank: rarityRank ?? this.rarityRank,
      isVerified: isVerified ?? this.isVerified,
      externalLink: externalLink ?? this.externalLink,
      metadata: metadata ?? this.metadata,
    );
  }
}

class NFTCollection extends Equatable {
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String bannerImageUrl;
  final String contractAddress;
  final double? floorPrice;
  final double? totalVolume;
  final int totalSupply;
  final int ownersCount;
  final bool isVerified;
  final String? externalLink;
  final Map<String, dynamic> stats;

  const NFTCollection({
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.bannerImageUrl,
    required this.contractAddress,
    this.floorPrice,
    this.totalVolume,
    required this.totalSupply,
    required this.ownersCount,
    this.isVerified = false,
    this.externalLink,
    this.stats = const {},
  });

  @override
  List<Object?> get props => [
        name,
        slug,
        description,
        imageUrl,
        bannerImageUrl,
        contractAddress,
        floorPrice,
        totalVolume,
        totalSupply,
        ownersCount,
        isVerified,
        externalLink,
        stats,
      ];
}

class NFTSale extends Equatable {
  final String id;
  final String nftId;
  final String collectionName;
  final String imageUrl;
  final double price;
  final String currency;
  final DateTime saleDate;
  final String buyer;
  final String seller;
  final String transactionHash;

  const NFTSale({
    required this.id,
    required this.nftId,
    required this.collectionName,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.saleDate,
    required this.buyer,
    required this.seller,
    required this.transactionHash,
  });

  @override
  List<Object?> get props => [
        id,
        nftId,
        collectionName,
        imageUrl,
        price,
        currency,
        saleDate,
        buyer,
        seller,
        transactionHash,
      ];
}
