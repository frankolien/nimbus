import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/core/services/input_validation_service.dart';
import 'package:nimbus/core/services/security_service.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('InputValidationService Tests', () {
    group('Ethereum Address Validation', () {
      test('should validate correct Ethereum address', () {
        const validAddress = '0x742d35cc6634c0532925a3b8d4c9db96c4b4d8b6';
        final result =
            InputValidationService.validateEthereumAddress(validAddress);

        expect(result.isValid, true);
        expect(result.message, 'Valid Ethereum address');
      });

      test('should reject empty address', () {
        const emptyAddress = '';
        final result =
            InputValidationService.validateEthereumAddress(emptyAddress);

        expect(result.isValid, false);
        expect(result.message, 'Address cannot be empty');
      });

      test('should reject address without 0x prefix', () {
        const invalidAddress = '742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
        final result =
            InputValidationService.validateEthereumAddress(invalidAddress);

        expect(result.isValid, false);
        expect(result.message, 'Ethereum address must start with 0x');
      });

      test('should reject address with wrong length', () {
        const invalidAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b';
        final result =
            InputValidationService.validateEthereumAddress(invalidAddress);

        expect(result.isValid, false);
        expect(result.message, 'Ethereum address must be 42 characters long');
      });

      test('should reject address with invalid characters', () {
        const invalidAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8bG';
        final result =
            InputValidationService.validateEthereumAddress(invalidAddress);

        expect(result.isValid, false);
        expect(result.message, 'Invalid Ethereum address format');
      });
    });

    group('Crypto Amount Validation', () {
      test('should validate correct amount', () {
        const validAmount = '1.5';
        final result = InputValidationService.validateCryptoAmount(validAmount);

        expect(result.isValid, true);
        expect(result.message, 'Valid amount');
      });

      test('should reject empty amount', () {
        const emptyAmount = '';
        final result = InputValidationService.validateCryptoAmount(emptyAmount);

        expect(result.isValid, false);
        expect(result.message, 'Amount cannot be empty');
      });

      test('should reject negative amount', () {
        const negativeAmount = '-1.5';
        final result =
            InputValidationService.validateCryptoAmount(negativeAmount);

        expect(result.isValid, false);
        expect(result.message, 'Amount must be greater than 0');
      });

      test('should reject zero amount', () {
        const zeroAmount = '0';
        final result = InputValidationService.validateCryptoAmount(zeroAmount);

        expect(result.isValid, false);
        expect(result.message, 'Amount must be greater than 0');
      });

      test('should reject invalid number format', () {
        const invalidAmount = 'abc';
        final result =
            InputValidationService.validateCryptoAmount(invalidAmount);

        expect(result.isValid, false);
        expect(result.message, 'Amount must be a valid number');
      });

      test('should reject amount with too many decimal places', () {
        const invalidAmount = '1.1234567890123456789';
        final result = InputValidationService.validateCryptoAmount(
            invalidAmount,
            decimals: 6);

        expect(result.isValid, false);
        expect(result.message, 'Amount has too many decimal places (max 6)');
      });
    });

    group('Passcode Validation', () {
      test('should validate correct 4-digit passcode', () {
        const validPasscode = '1234';
        final result = InputValidationService.validatePasscode(validPasscode);

        expect(result.isValid, true);
        expect(result.message, 'Valid passcode');
      });

      test('should validate correct 6-digit passcode', () {
        const validPasscode = '123456';
        final result = InputValidationService.validatePasscode(validPasscode);

        expect(result.isValid, true);
        expect(result.message, 'Valid passcode');
      });

      test('should reject empty passcode', () {
        const emptyPasscode = '';
        final result = InputValidationService.validatePasscode(emptyPasscode);

        expect(result.isValid, false);
        expect(result.message, 'Passcode cannot be empty');
      });

      test('should reject passcode with letters', () {
        const invalidPasscode = '123a';
        final result = InputValidationService.validatePasscode(invalidPasscode);

        expect(result.isValid, false);
        expect(result.message, 'Passcode must be 4-6 digits');
      });

      test('should reject passcode that is too short', () {
        const invalidPasscode = '123';
        final result = InputValidationService.validatePasscode(invalidPasscode);

        expect(result.isValid, false);
        expect(result.message, 'Passcode must be 4-6 digits');
      });

      test('should reject passcode that is too long', () {
        const invalidPasscode = '1234567';
        final result = InputValidationService.validatePasscode(invalidPasscode);

        expect(result.isValid, false);
        expect(result.message, 'Passcode must be 4-6 digits');
      });
    });

    group('User Input Validation', () {
      test('should validate safe input', () {
        const safeInput = 'Hello World';
        final result = InputValidationService.validateUserInput(safeInput);

        expect(result.isValid, true);
        expect(result.message, 'Valid input');
      });

      test('should reject input with script tags', () {
        const maliciousInput = '<script>alert("xss")</script>';
        final result = InputValidationService.validateUserInput(maliciousInput);

        expect(result.isValid, false);
        expect(result.message, 'Input contains potentially malicious content');
      });

      test('should reject input with javascript protocol', () {
        const maliciousInput = 'javascript:alert("xss")';
        final result = InputValidationService.validateUserInput(maliciousInput);

        expect(result.isValid, false);
        expect(result.message, 'Input contains potentially malicious content');
      });

      test('should reject input that is too long', () {
        final longInput = 'a' * 1001;
        final result = InputValidationService.validateUserInput(longInput,
            maxLength: 1000);

        expect(result.isValid, false);
        expect(result.message, 'Input is too long (max 1000 characters)');
      });
    });
  });

  group('SecurityService Tests', () {
    group('Password Hashing', () {
      test('should hash password successfully', () async {
        const password = 'testPassword123';
        final hash = await SecurityService.hashPassword(password);

        expect(hash, isNotEmpty);
        expect(hash, isNot(equals(password)));
      });

      test('should verify correct password', () async {
        const password = 'testPassword123';
        final hash = await SecurityService.hashPassword(password);
        final isValid = await SecurityService.verifyPassword(password, hash);

        expect(isValid, true);
      });

      test('should reject incorrect password', () async {
        const password = 'testPassword123';
        const wrongPassword = 'wrongPassword';
        final hash = await SecurityService.hashPassword(password);
        final isValid =
            await SecurityService.verifyPassword(wrongPassword, hash);

        expect(isValid, false);
      });
    });

    group('Password Strength Validation', () {
      test('should accept strong password', () {
        const strongPassword = 'StrongPass123!';
        final result = SecurityService.validatePasswordStrength(strongPassword);

        expect(result.isValid, true);
        expect(result.message, 'Password is strong');
      });

      test('should reject short password', () {
        const shortPassword = 'short';
        final result = SecurityService.validatePasswordStrength(shortPassword);

        expect(result.isValid, false);
        expect(result.message, 'Password must be at least 8 characters long');
      });

      test('should reject common password', () {
        const commonPassword = 'password';
        final result = SecurityService.validatePasswordStrength(commonPassword);

        expect(result.isValid, false);
        expect(result.message,
            'Password is too common. Please choose a stronger password.');
      });

      test('should reject password without uppercase', () {
        const weakPassword = 'weakpass123';
        final result = SecurityService.validatePasswordStrength(weakPassword);

        expect(result.isValid, false);
        expect(result.message,
            'Password must contain uppercase, lowercase, and numbers');
      });

      test('should reject password without lowercase', () {
        const weakPassword = 'WEAKPASS123';
        final result = SecurityService.validatePasswordStrength(weakPassword);

        expect(result.isValid, false);
        expect(result.message,
            'Password must contain uppercase, lowercase, and numbers');
      });

      test('should reject password without numbers', () {
        const weakPassword = 'WeakPass';
        final result = SecurityService.validatePasswordStrength(weakPassword);

        expect(result.isValid, false);
        expect(result.message,
            'Password must contain uppercase, lowercase, and numbers');
      });
    });

    group('Passcode Validation', () {
      test('should validate correct passcode format', () {
        const validPasscode = '1234';
        final isValid = SecurityService.isValidPasscode(validPasscode);

        expect(isValid, true);
      });

      test('should validate 6-digit passcode', () {
        const validPasscode = '123456';
        final isValid = SecurityService.isValidPasscode(validPasscode);

        expect(isValid, true);
      });

      test('should reject passcode with letters', () {
        const invalidPasscode = '123a';
        final isValid = SecurityService.isValidPasscode(invalidPasscode);

        expect(isValid, false);
      });

      test('should reject short passcode', () {
        const invalidPasscode = '123';
        final isValid = SecurityService.isValidPasscode(invalidPasscode);

        expect(isValid, false);
      });

      test('should reject long passcode', () {
        const invalidPasscode = '1234567';
        final isValid = SecurityService.isValidPasscode(invalidPasscode);

        expect(isValid, false);
      });
    });

    group('Secure Passcode Generation', () {
      test('should generate 6-digit passcode', () {
        final passcode = SecurityService.generateSecurePasscode();

        expect(passcode.length, 6);
        expect(RegExp(r'^\d{6}$').hasMatch(passcode), true);
      });

      test('should generate different passcodes', () {
        final passcode1 = SecurityService.generateSecurePasscode();
        final passcode2 = SecurityService.generateSecurePasscode();

        expect(passcode1, isNot(equals(passcode2)));
      });
    });

    group('Data Sanitization', () {
      test('should sanitize input for display', () {
        const input = 'Hello<script>alert("xss")</script>World';
        final sanitized = SecurityService.sanitizeForDisplay(input);

        expect(sanitized, 'Helloscriptalert(xss)/scriptWorld');
        expect(sanitized.contains('<'), false);
        expect(sanitized.contains('>'), false);
      });

      test('should handle empty input', () {
        const input = '';
        final sanitized = SecurityService.sanitizeForDisplay(input);

        expect(sanitized, '');
      });

      test('should remove control characters', () {
        const input = 'Hello\x00World\x1F';
        final sanitized = SecurityService.sanitizeForDisplay(input);

        expect(sanitized, 'HelloWorld');
      });
    });

    group('Logging Hash', () {
      test('should hash short data', () {
        const data = 'ab';
        final hashed = SecurityService.hashForLogging(data);

        expect(hashed, '***');
      });

      test('should hash medium data', () {
        const data = 'abcdef';
        final hashed = SecurityService.hashForLogging(data);

        expect(hashed, 'ab***ef');
      });

      test('should hash long data', () {
        const data = 'abcdefghijklmnop';
        final hashed = SecurityService.hashForLogging(data);

        expect(hashed, 'ab***op');
      });
    });
  });
}
