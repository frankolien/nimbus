// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nftStatsHash() => r'26ab8948f610c3d5c1bc146913d96e1ece9f5fb3';

/// See also [nftStats].
@ProviderFor(nftStats)
final nftStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  nftStats,
  name: r'nftStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$nftStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NftStatsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$nFTNotifierHash() => r'305a14477d3b4eb8e9f739a42d3e232988c9fb87';

/// See also [NFTNotifier].
@ProviderFor(NFTNotifier)
final nFTNotifierProvider =
    AutoDisposeAsyncNotifierProvider<NFTNotifier, List<NFT>>.internal(
  NFTNotifier.new,
  name: r'nFTNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$nFTNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NFTNotifier = AutoDisposeAsyncNotifier<List<NFT>>;
String _$nFTSalesNotifierHash() => r'f22537e1c4db74ab7e8fd481903918e22ce783be';

/// See also [NFTSalesNotifier].
@ProviderFor(NFTSalesNotifier)
final nFTSalesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<NFTSalesNotifier, List<NFTSale>>.internal(
  NFTSalesNotifier.new,
  name: r'nFTSalesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nFTSalesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NFTSalesNotifier = AutoDisposeAsyncNotifier<List<NFTSale>>;
String _$nFTCollectionsNotifierHash() =>
    r'd756bf338535d586eea12ff728199c8c2def22f5';

/// See also [NFTCollectionsNotifier].
@ProviderFor(NFTCollectionsNotifier)
final nFTCollectionsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    NFTCollectionsNotifier, List<NFTCollection>>.internal(
  NFTCollectionsNotifier.new,
  name: r'nFTCollectionsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nFTCollectionsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NFTCollectionsNotifier
    = AutoDisposeAsyncNotifier<List<NFTCollection>>;
String _$nFTCategoryNotifierHash() =>
    r'91c486d2c7ee60686dbfbff00842580ffa381a52';

/// See also [NFTCategoryNotifier].
@ProviderFor(NFTCategoryNotifier)
final nFTCategoryNotifierProvider =
    AutoDisposeNotifierProvider<NFTCategoryNotifier, String>.internal(
  NFTCategoryNotifier.new,
  name: r'nFTCategoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nFTCategoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NFTCategoryNotifier = AutoDisposeNotifier<String>;
String _$nFTSearchNotifierHash() => r'6e6fe04a7af62ff1d06f8b2b20839d963428bdc6';

/// See also [NFTSearchNotifier].
@ProviderFor(NFTSearchNotifier)
final nFTSearchNotifierProvider =
    AutoDisposeNotifierProvider<NFTSearchNotifier, String>.internal(
  NFTSearchNotifier.new,
  name: r'nFTSearchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nFTSearchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NFTSearchNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
