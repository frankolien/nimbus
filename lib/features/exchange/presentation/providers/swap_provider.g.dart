// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$swapStateHash() => r'dec8d84c41be92000ebce0ef1cf0ce93011e65dc';

/// See also [SwapState].
@ProviderFor(SwapState)
final swapStateProvider =
    AutoDisposeNotifierProvider<SwapState, AsyncValue<SwapQuote?>>.internal(
  SwapState.new,
  name: r'swapStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$swapStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SwapState = AutoDisposeNotifier<AsyncValue<SwapQuote?>>;
String _$swapExecutionHash() => r'99a859f1b86c0febb2986d60bcefa6586e5f70f2';

/// See also [SwapExecution].
@ProviderFor(SwapExecution)
final swapExecutionProvider =
    AutoDisposeNotifierProvider<SwapExecution, AsyncValue<String?>>.internal(
  SwapExecution.new,
  name: r'swapExecutionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swapExecutionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SwapExecution = AutoDisposeNotifier<AsyncValue<String?>>;
String _$swapFormHash() => r'b39329040e3edd87e24054d04ae37845355fa7a7';

/// See also [SwapForm].
@ProviderFor(SwapForm)
final swapFormProvider =
    AutoDisposeNotifierProvider<SwapForm, SwapFormData>.internal(
  SwapForm.new,
  name: r'swapFormProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$swapFormHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SwapForm = AutoDisposeNotifier<SwapFormData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
