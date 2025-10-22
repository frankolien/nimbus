import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;
  final String? name;
  final bool isEmailVerified;
  final DateTime? lastLogin;

  const User({
    required this.email,
    this.name,
    this.isEmailVerified = false,
    this.lastLogin,
  });

  User copyWith({
    String? email,
    String? name,
    bool? isEmailVerified,
    DateTime? lastLogin,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [email, name, isEmailVerified, lastLogin];
}
