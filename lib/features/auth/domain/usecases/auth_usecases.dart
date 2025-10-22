import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository _repository;

  LoginWithEmailUseCase(this._repository);

  Future<User> call(String email) async {
    return await _repository.loginWithEmail(email);
  }
}

class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<User> call(String verificationCode) async {
    return await _repository.verifyEmail(verificationCode);
  }
}

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() async {
    return await _repository.logout();
  }
}
