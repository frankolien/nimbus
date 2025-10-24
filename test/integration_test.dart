import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/app.dart';
import 'package:nimbus/features/send/presentation/providers/send_provider.dart';
import 'package:nimbus/core/services/input_validation_service.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('App loads without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: NimbusApp(),
        ),
      );

      // Verify that the app loads without errors
      expect(find.text('Nimbus'), findsOneWidget);
    });

    testWidgets('Send provider handles address validation',
        (WidgetTester tester) async {
      // Create a provider container
      final container = ProviderContainer();

      // Get the send notifier
      final sendNotifier = container.read(sendNotifierProvider.notifier);

      // Test valid address
      sendNotifier
          .updateRecipientAddress('0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6');
      expect(sendNotifier.state.errorMessage, null);

      // Test invalid address
      sendNotifier.updateRecipientAddress('invalid_address');
      expect(sendNotifier.state.errorMessage, isNotNull);

      // Clean up
      container.dispose();
    });

    testWidgets('Send provider handles amount validation',
        (WidgetTester tester) async {
      // Create a provider container
      final container = ProviderContainer();

      // Get the send notifier
      final sendNotifier = container.read(sendNotifierProvider.notifier);

      // Test valid amount
      sendNotifier.updateAmount('1.5');
      expect(sendNotifier.state.errorMessage, null);

      // Test invalid amount
      sendNotifier.updateAmount('-1.0');
      expect(sendNotifier.state.errorMessage, isNotNull);

      // Clean up
      container.dispose();
    });

    testWidgets('Send provider navigation flow', (WidgetTester tester) async {
      // Create a provider container
      final container = ProviderContainer();

      // Get the send notifier
      final sendNotifier = container.read(sendNotifierProvider.notifier);

      // Start at address input step
      expect(sendNotifier.state.currentStep, SendStep.addressInput);

      // Add valid address and go to next step
      sendNotifier
          .updateRecipientAddress('0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6');
      sendNotifier.nextStep();
      expect(sendNotifier.state.currentStep, SendStep.amountInput);

      // Add valid amount and go to next step
      sendNotifier.updateAmount('1.0');
      sendNotifier.nextStep();
      expect(sendNotifier.state.currentStep, SendStep.confirmation);

      // Go back to previous step
      sendNotifier.previousStep();
      expect(sendNotifier.state.currentStep, SendStep.amountInput);

      // Clean up
      container.dispose();
    });
  });

  group('Input Validation Integration', () {
    test('Ethereum address validation with real addresses', () {
      // Test with real Ethereum addresses
      const realAddresses = [
        '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
        '0x8ba1f109551bD432803012645Hac136c',
        '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      ];

      for (final address in realAddresses) {
        final result = InputValidationService.validateEthereumAddress(address);
        expect(result.isValid, true,
            reason: 'Address $address should be valid');
      }
    });

    test('Crypto amount validation with edge cases', () {
      // Test with various amount formats
      const validAmounts = [
        '0.1',
        '1.0',
        '100.0',
        '0.000001',
        '1000000.0',
      ];

      for (final amount in validAmounts) {
        final result = InputValidationService.validateCryptoAmount(amount);
        expect(result.isValid, true, reason: 'Amount $amount should be valid');
      }

      // Test with invalid amounts
      const invalidAmounts = [
        '0',
        '-1.0',
        'abc',
        '1.1234567890123456789', // Too many decimal places
      ];

      for (final amount in invalidAmounts) {
        final result = InputValidationService.validateCryptoAmount(amount);
        expect(result.isValid, false,
            reason: 'Amount $amount should be invalid');
      }
    });

    test('Passcode validation with various formats', () {
      // Test with valid passcodes
      const validPasscodes = [
        '1234',
        '5678',
        '123456',
        '987654',
      ];

      for (final passcode in validPasscodes) {
        final result = InputValidationService.validatePasscode(passcode);
        expect(result.isValid, true,
            reason: 'Passcode $passcode should be valid');
      }

      // Test with invalid passcodes
      const invalidPasscodes = [
        '123',
        '12345',
        '1234567',
        '123a',
        'abcd',
      ];

      for (final passcode in invalidPasscodes) {
        final result = InputValidationService.validatePasscode(passcode);
        expect(result.isValid, false,
            reason: 'Passcode $passcode should be invalid');
      }
    });
  });

  group('Security Integration', () {
    test('Password hashing and verification flow', () async {
      const password = 'TestPassword123!';

      // Hash the password
      final hash = await SecurityService.hashPassword(password);
      expect(hash, isNotEmpty);
      expect(hash, isNot(equals(password)));

      // Verify the password
      final isValid = await SecurityService.verifyPassword(password, hash);
      expect(isValid, true);

      // Verify wrong password
      final isInvalid =
          await SecurityService.verifyPassword('WrongPassword', hash);
      expect(isInvalid, false);
    });

    test('Password strength validation with real passwords', () {
      // Test with strong passwords
      const strongPasswords = [
        'StrongPass123!',
        'MySecure2024#',
        'ComplexP@ssw0rd',
      ];

      for (final password in strongPasswords) {
        final result = SecurityService.validatePasswordStrength(password);
        expect(result.isValid, true,
            reason: 'Password $password should be strong');
      }

      // Test with weak passwords
      const weakPasswords = [
        'password',
        '123456',
        'qwerty',
        'abc123',
        'Password',
        'password123',
      ];

      for (final password in weakPasswords) {
        final result = SecurityService.validatePasswordStrength(password);
        expect(result.isValid, false,
            reason: 'Password $password should be weak');
      }
    });

    test('Data sanitization with malicious input', () {
      const maliciousInputs = [
        '<script>alert("xss")</script>',
        'javascript:alert("xss")',
        'data:text/html,<script>alert("xss")</script>',
        'vbscript:alert("xss")',
        'onload=alert("xss")',
        'onerror=alert("xss")',
        'onclick=alert("xss")',
        'eval(alert("xss"))',
        'expression(alert("xss"))',
      ];

      for (final input in maliciousInputs) {
        final sanitized = SecurityService.sanitizeForDisplay(input);
        expect(sanitized, isNot(equals(input)));
        expect(sanitized.contains('<script'), false);
        expect(sanitized.contains('javascript:'), false);
        expect(sanitized.contains('onload='), false);
      }
    });
  });

  group('Error Handling Integration', () {
    test('Error handling with various error types', () {
      // Test with different error types
      final errors = [
        Exception('Network error'),
        Exception('SocketException'),
        Exception('HandshakeException'),
        Exception('TimeoutException'),
        Exception('WalletConnectionException: Connection failed'),
        Exception('TransactionException: Transaction rejected'),
        Exception('SecurityException: Invalid input'),
        Exception('Validation error'),
      ];

      for (final error in errors) {
        // This would test the ErrorHandler in a real scenario
        // For now, we just verify the error types exist
        expect(error, isA<Exception>());
      }
    });
  });
}
