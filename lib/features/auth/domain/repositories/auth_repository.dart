import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> loginWithEmail(String email);
  Future<User> verifyEmail(String verificationCode);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
}
