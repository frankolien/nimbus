import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class LocalAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _passcodeKey = 'user_passcode';
  static const String _isSetupKey = 'auth_setup_complete';

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Nimbus',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  /// Set up passcode for the first time
  Future<bool> setupPasscode(String passcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Hash the passcode (simple base64 encoding for demo - use proper hashing in production)
      final encodedPasscode = base64Encode(utf8.encode(passcode));
      await prefs.setString(_passcodeKey, encodedPasscode);
      await prefs.setBool(_isSetupKey, true);
      return true;
    } catch (e) {
      print('Error setting up passcode: $e');
      return false;
    }
  }

  /// Verify passcode
  Future<bool> verifyPasscode(String passcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPasscode = prefs.getString(_passcodeKey);
      if (storedPasscode == null) return false;

      final encodedPasscode = base64Encode(utf8.encode(passcode));
      return storedPasscode == encodedPasscode;
    } catch (e) {
      print('Error verifying passcode: $e');
      return false;
    }
  }

  /// Check if authentication is set up
  Future<bool> isAuthSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isSetupKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_passcodeKey);
      await prefs.remove(_isSetupKey);
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  /// Validate passcode format (4-6 digits)
  bool isValidPasscode(String passcode) {
    // Check if passcode is 4-6 digits only
    final regex = RegExp(r'^\d{4,6}$');
    return regex.hasMatch(passcode);
  }

  /// Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> biometrics) {
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }
}

// Provider for LocalAuthService
final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthService();
});

// Provider for authentication setup status
final isAuthSetupProvider = FutureProvider<bool>((ref) {
  final authService = ref.watch(localAuthServiceProvider);
  return authService.isAuthSetup();
});

// Provider for biometric availability
final biometricAvailableProvider = FutureProvider<bool>((ref) {
  final authService = ref.watch(localAuthServiceProvider);
  return authService.isBiometricAvailable();
});
