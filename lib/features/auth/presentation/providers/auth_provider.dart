import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_provider.g.dart';

// Auth state
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<User?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loginWithEmail(String email) async {
    state = const AsyncValue.loading();

    try {
      // Simulate email verification process
      await Future.delayed(const Duration(seconds: 2));

      final user = User(
        email: email,
        isEmailVerified: false,
        lastLogin: DateTime.now(),
      );

      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> verifyEmail(String verificationCode) async {
    if (state.hasValue && state.value != null) {
      state = const AsyncValue.loading();

      try {
        // Simulate email verification
        await Future.delayed(const Duration(seconds: 1));

        final verifiedUser = state.value!.copyWith(
          isEmailVerified: true,
        );

        state = AsyncValue.data(verifiedUser);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.data(null);
  }
}

// Auth status providers
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.hasValue &&
      authState.value != null &&
      authState.value!.isEmailVerified;
}

@riverpod
bool isEmailVerified(IsEmailVerifiedRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.hasValue &&
      authState.value != null &&
      authState.value!.isEmailVerified;
}

@riverpod
String? currentUserEmail(CurrentUserEmailRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.email;
}
