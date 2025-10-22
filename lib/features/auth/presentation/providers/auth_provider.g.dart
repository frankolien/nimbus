// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAuthenticatedHash() => r'bf6b13f074ab3ebf4bf0491d7a66e850351346ef';

/// See also [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$isEmailVerifiedHash() => r'6fdb666eda96ee278a8bb6cfb89b3e8d94710332';

/// See also [isEmailVerified].
@ProviderFor(isEmailVerified)
final isEmailVerifiedProvider = AutoDisposeProvider<bool>.internal(
  isEmailVerified,
  name: r'isEmailVerifiedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isEmailVerifiedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsEmailVerifiedRef = AutoDisposeProviderRef<bool>;
String _$currentUserEmailHash() => r'9051bf6f70bab587101bf58d005749a67645a8ad';

/// See also [currentUserEmail].
@ProviderFor(currentUserEmail)
final currentUserEmailProvider = AutoDisposeProvider<String?>.internal(
  currentUserEmail,
  name: r'currentUserEmailProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserEmailHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserEmailRef = AutoDisposeProviderRef<String?>;
String _$authStateHash() => r'ed46e1abbd15d79477cafdac7565c491e3232fcd';

/// See also [AuthState].
@ProviderFor(AuthState)
final authStateProvider =
    AutoDisposeNotifierProvider<AuthState, AsyncValue<User?>>.internal(
  AuthState.new,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthState = AutoDisposeNotifier<AsyncValue<User?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
