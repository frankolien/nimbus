// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletConnectedHash() => r'85f7e4d95c38b9de0742ce97a187a3de89c5e01f';

/// See also [walletConnected].
@ProviderFor(walletConnected)
final walletConnectedProvider = AutoDisposeProvider<bool>.internal(
  walletConnected,
  name: r'walletConnectedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walletConnectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletConnectedRef = AutoDisposeProviderRef<bool>;
String _$currentWalletAddressHash() =>
    r'77d7e360cae9ed5f2d2356597ddfba2a2c6983dc';

/// See also [currentWalletAddress].
@ProviderFor(currentWalletAddress)
final currentWalletAddressProvider = AutoDisposeProvider<String?>.internal(
  currentWalletAddress,
  name: r'currentWalletAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentWalletAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentWalletAddressRef = AutoDisposeProviderRef<String?>;
String _$walletStateHash() => r'c38a65465024847e3543982aa42281e1baa7a998';

/// See also [WalletState].
@ProviderFor(WalletState)
final walletStateProvider =
    AutoDisposeNotifierProvider<WalletState, AsyncValue<Wallet?>>.internal(
  WalletState.new,
  name: r'walletStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$walletStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WalletState = AutoDisposeNotifier<AsyncValue<Wallet?>>;
String _$tokenBalancesHash() => r'bedff17c8f5924f906d7524bff7e9660db946d16';

/// See also [TokenBalances].
@ProviderFor(TokenBalances)
final tokenBalancesProvider = AutoDisposeNotifierProvider<TokenBalances,
    AsyncValue<List<Token>>>.internal(
  TokenBalances.new,
  name: r'tokenBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokenBalances = AutoDisposeNotifier<AsyncValue<List<Token>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
