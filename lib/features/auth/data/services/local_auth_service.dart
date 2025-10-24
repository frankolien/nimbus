import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/security_service.dart';

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
      // Validate passcode format
      if (!SecurityService.isValidPasscode(passcode)) {
        throw SecurityException('Invalid passcode format');
      }

      // Check if account is locked
      if (await SecurityService.isAccountLocked()) {
        throw SecurityException(
            'Account is locked due to too many failed attempts');
      }

      // Hash the passcode using Argon2id
      final hashedPasscode = await SecurityService.hashPassword(passcode);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_passcodeKey, hashedPasscode);
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
      // Check if account is locked
      if (await SecurityService.isAccountLocked()) {
        throw SecurityException(
            'Account is locked due to too many failed attempts');
      }

      final prefs = await SharedPreferences.getInstance();
      final storedPasscode = prefs.getString(_passcodeKey);

      if (storedPasscode == null) {
        await SecurityService.recordFailedLogin();
        return false;
      }

      // Verify the passcode using Argon2id
      final isValid =
          await SecurityService.verifyPassword(passcode, storedPasscode);

      if (isValid) {
        // Reset failed login attempts on successful verification
        await _resetLoginAttempts();
      } else {
        await SecurityService.recordFailedLogin();
      }

      return isValid;
    } catch (e) {
      print('Error verifying passcode: $e');
      await SecurityService.recordFailedLogin();
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

  /// Reset login attempts after successful authentication
  Future<void> _resetLoginAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('login_attempts');
      await prefs.remove('last_login_attempt');
    } catch (e) {
      print('Error resetting login attempts: $e');
    }
  }

  /// Validate passcode format (4-6 digits)
  bool isValidPasscode(String passcode) {
    return SecurityService.isValidPasscode(passcode);
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
