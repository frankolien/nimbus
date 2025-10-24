// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nftSearchResultsHash() => r'f0777e03bfeb3759dfdfac2f4cc020a081f82913';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [nftSearchResults].
@ProviderFor(nftSearchResults)
const nftSearchResultsProvider = NftSearchResultsFamily();

/// See also [nftSearchResults].
class NftSearchResultsFamily extends Family<AsyncValue<List<NFT>>> {
  /// See also [nftSearchResults].
  const NftSearchResultsFamily();

  /// See also [nftSearchResults].
  NftSearchResultsProvider call(
    String query,
  ) {
    return NftSearchResultsProvider(
      query,
    );
  }

  @override
  NftSearchResultsProvider getProviderOverride(
    covariant NftSearchResultsProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'nftSearchResultsProvider';
}

/// See also [nftSearchResults].
class NftSearchResultsProvider extends AutoDisposeFutureProvider<List<NFT>> {
  /// See also [nftSearchResults].
  NftSearchResultsProvider(
    String query,
  ) : this._internal(
          (ref) => nftSearchResults(
            ref as NftSearchResultsRef,
            query,
          ),
          from: nftSearchResultsProvider,
          name: r'nftSearchResultsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nftSearchResultsHash,
          dependencies: NftSearchResultsFamily._dependencies,
          allTransitiveDependencies:
              NftSearchResultsFamily._allTransitiveDependencies,
          query: query,
        );

  NftSearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<NFT>> Function(NftSearchResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NftSearchResultsProvider._internal(
        (ref) => create(ref as NftSearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<NFT>> createElement() {
    return _NftSearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NftSearchResultsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NftSearchResultsRef on AutoDisposeFutureProviderRef<List<NFT>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _NftSearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<NFT>>
    with NftSearchResultsRef {
  _NftSearchResultsProviderElement(super.provider);

  @override
  String get query => (origin as NftSearchResultsProvider).query;
}

String _$nftPurchaseInfoHash() => r'16014cb642f0a0d0a529ce872730c8784385a896';

/// See also [nftPurchaseInfo].
@ProviderFor(nftPurchaseInfo)
const nftPurchaseInfoProvider = NftPurchaseInfoFamily();

/// See also [nftPurchaseInfo].
class NftPurchaseInfoFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [nftPurchaseInfo].
  const NftPurchaseInfoFamily();

  /// See also [nftPurchaseInfo].
  NftPurchaseInfoProvider call(
    String contractAddress,
    String tokenId,
  ) {
    return NftPurchaseInfoProvider(
      contractAddress,
      tokenId,
    );
  }

  @override
  NftPurchaseInfoProvider getProviderOverride(
    covariant NftPurchaseInfoProvider provider,
  ) {
    return call(
      provider.contractAddress,
      provider.tokenId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'nftPurchaseInfoProvider';
}

/// See also [nftPurchaseInfo].
class NftPurchaseInfoProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [nftPurchaseInfo].
  NftPurchaseInfoProvider(
    String contractAddress,
    String tokenId,
  ) : this._internal(
          (ref) => nftPurchaseInfo(
            ref as NftPurchaseInfoRef,
            contractAddress,
            tokenId,
          ),
          from: nftPurchaseInfoProvider,
          name: r'nftPurchaseInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nftPurchaseInfoHash,
          dependencies: NftPurchaseInfoFamily._dependencies,
          allTransitiveDependencies:
              NftPurchaseInfoFamily._allTransitiveDependencies,
          contractAddress: contractAddress,
          tokenId: tokenId,
        );

  NftPurchaseInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contractAddress,
    required this.tokenId,
  }) : super.internal();

  final String contractAddress;
  final String tokenId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(NftPurchaseInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NftPurchaseInfoProvider._internal(
        (ref) => create(ref as NftPurchaseInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contractAddress: contractAddress,
        tokenId: tokenId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _NftPurchaseInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NftPurchaseInfoProvider &&
        other.contractAddress == contractAddress &&
        other.tokenId == tokenId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contractAddress.hashCode);
    hash = _SystemHash.combine(hash, tokenId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NftPurchaseInfoRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `contractAddress` of this provider.
  String get contractAddress;

  /// The parameter `tokenId` of this provider.
  String get tokenId;
}

class _NftPurchaseInfoProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with NftPurchaseInfoRef {
  _NftPurchaseInfoProviderElement(super.provider);

  @override
  String get contractAddress =>
      (origin as NftPurchaseInfoProvider).contractAddress;
  @override
  String get tokenId => (origin as NftPurchaseInfoProvider).tokenId;
}

String _$nftStatsHash() => r'045fc162dfa46d4682c3df76b89e93a0c633fe3d';

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
String _$nFTNotifierHash() => r'45e56066448b5e51b22255562433c1289d0087df';

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
