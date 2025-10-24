import 'package:web3dart/web3dart.dart';

/// Comprehensive input validation service for crypto operations
/// Prevents injection attacks, invalid addresses, and malicious inputs
class InputValidationService {
  /// Validate Ethereum address format
  static ValidationResult validateEthereumAddress(String address) {
    if (address.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Address cannot be empty',
      );
    }

    // Remove whitespace
    address = address.trim();

    // Check if it starts with 0x
    if (!address.startsWith('0x')) {
      return ValidationResult(
        isValid: false,
        message: 'Ethereum address must start with 0x',
      );
    }

    // Check length (42 characters: 0x + 40 hex chars)
    if (address.length != 42) {
      return ValidationResult(
        isValid: false,
        message: 'Ethereum address must be 42 characters long',
      );
    }

    // Check if it's valid hex
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address)) {
      return ValidationResult(
        isValid: false,
        message: 'Invalid Ethereum address format',
      );
    }

    // Check if it's a valid checksum address
    try {
      EthereumAddress.fromHex(address);
      return ValidationResult(
        isValid: true,
        message: 'Valid Ethereum address',
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        message: 'Invalid Ethereum address checksum',
      );
    }
  }

  /// Validate Solana address format
  static ValidationResult validateSolanaAddress(String address) {
    if (address.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Address cannot be empty',
      );
    }

    address = address.trim();

    // Solana addresses are base58 encoded and typically 32-44 characters
    if (address.length < 32 || address.length > 44) {
      return ValidationResult(
        isValid: false,
        message: 'Solana address must be 32-44 characters long',
      );
    }

    // Check if it's valid base58
    if (!RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address)) {
      return ValidationResult(
        isValid: false,
        message: 'Invalid Solana address format (must be base58)',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid Solana address',
    );
  }

  /// Validate crypto amount
  static ValidationResult validateCryptoAmount(String amount,
      {int decimals = 18}) {
    if (amount.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Amount cannot be empty',
      );
    }

    amount = amount.trim();

    // Check if it's a valid number
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) {
      return ValidationResult(
        isValid: false,
        message: 'Amount must be a valid number',
      );
    }

    // Check if it's positive
    if (parsedAmount <= 0) {
      return ValidationResult(
        isValid: false,
        message: 'Amount must be greater than 0',
      );
    }

    // Check if it's not too large (prevent overflow)
    if (parsedAmount > 1e15) {
      return ValidationResult(
        isValid: false,
        message: 'Amount is too large',
      );
    }

    // Check decimal places
    final parts = amount.split('.');
    if (parts.length == 2 && parts[1].length > decimals) {
      return ValidationResult(
        isValid: false,
        message: 'Amount has too many decimal places (max $decimals)',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid amount',
    );
  }

  /// Validate gas price
  static ValidationResult validateGasPrice(String gasPrice) {
    if (gasPrice.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Gas price cannot be empty',
      );
    }

    gasPrice = gasPrice.trim();

    // Check if it's a valid number
    final parsedGasPrice = double.tryParse(gasPrice);
    if (parsedGasPrice == null) {
      return ValidationResult(
        isValid: false,
        message: 'Gas price must be a valid number',
      );
    }

    // Check if it's positive
    if (parsedGasPrice <= 0) {
      return ValidationResult(
        isValid: false,
        message: 'Gas price must be greater than 0',
      );
    }

    // Check if it's reasonable (not too high)
    if (parsedGasPrice > 1000) {
      // 1000 Gwei is extremely high
      return ValidationResult(
        isValid: false,
        message: 'Gas price is too high (max 1000 Gwei)',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid gas price',
    );
  }

  /// Validate gas limit
  static ValidationResult validateGasLimit(String gasLimit) {
    if (gasLimit.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Gas limit cannot be empty',
      );
    }

    gasLimit = gasLimit.trim();

    // Check if it's a valid integer
    final parsedGasLimit = int.tryParse(gasLimit);
    if (parsedGasLimit == null) {
      return ValidationResult(
        isValid: false,
        message: 'Gas limit must be a valid integer',
      );
    }

    // Check if it's positive
    if (parsedGasLimit <= 0) {
      return ValidationResult(
        isValid: false,
        message: 'Gas limit must be greater than 0',
      );
    }

    // Check if it's reasonable (not too high)
    if (parsedGasLimit > 10000000) {
      // 10M gas is extremely high
      return ValidationResult(
        isValid: false,
        message: 'Gas limit is too high (max 10,000,000)',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid gas limit',
    );
  }

  /// Validate transaction data (hex string)
  static ValidationResult validateTransactionData(String data) {
    if (data.isEmpty) {
      return ValidationResult(
        isValid: true, // Empty data is valid
        message: 'Valid transaction data',
      );
    }

    data = data.trim();

    // Check if it starts with 0x
    if (!data.startsWith('0x')) {
      return ValidationResult(
        isValid: false,
        message: 'Transaction data must start with 0x',
      );
    }

    // Check if it's valid hex
    if (!RegExp(r'^0x[0-9a-fA-F]*$').hasMatch(data)) {
      return ValidationResult(
        isValid: false,
        message: 'Transaction data must be valid hex',
      );
    }

    // Check if it's not too long (prevent DoS)
    if (data.length > 10000) {
      return ValidationResult(
        isValid: false,
        message: 'Transaction data is too long',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid transaction data',
    );
  }

  /// Validate passcode format
  static ValidationResult validatePasscode(String passcode) {
    if (passcode.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Passcode cannot be empty',
      );
    }

    // Check if it's 4-6 digits
    if (!RegExp(r'^\d{4,6}$').hasMatch(passcode)) {
      return ValidationResult(
        isValid: false,
        message: 'Passcode must be 4-6 digits',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid passcode',
    );
  }

  /// Validate user input for XSS prevention
  static ValidationResult validateUserInput(String input,
      {int maxLength = 1000}) {
    if (input.isEmpty) {
      return ValidationResult(
        isValid: true, // Empty input is valid
        message: 'Valid input',
      );
    }

    // Check length
    if (input.length > maxLength) {
      return ValidationResult(
        isValid: false,
        message: 'Input is too long (max $maxLength characters)',
      );
    }

    // Check for potentially malicious patterns
    final maliciousPatterns = [
      r'<script',
      r'javascript:',
      r'data:',
      r'vbscript:',
      r'onload=',
      r'onerror=',
      r'onclick=',
      r'eval\(',
      r'expression\(',
    ];

    for (final pattern in maliciousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return ValidationResult(
          isValid: false,
          message: 'Input contains potentially malicious content',
        );
      }
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid input',
    );
  }

  /// Validate network ID
  static ValidationResult validateNetworkId(String networkId) {
    if (networkId.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Network ID cannot be empty',
      );
    }

    final parsedId = int.tryParse(networkId);
    if (parsedId == null) {
      return ValidationResult(
        isValid: false,
        message: 'Network ID must be a valid number',
      );
    }

    // Check if it's a known network ID
    final knownNetworks = [1, 3, 4, 5, 42, 137, 80001]; // Ethereum networks
    if (!knownNetworks.contains(parsedId)) {
      return ValidationResult(
        isValid: false,
        message: 'Unknown network ID',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Valid network ID',
    );
  }

  /// Sanitize input for display (remove dangerous characters)
  static String sanitizeForDisplay(String input) {
    if (input.isEmpty) return input;

    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'[<>"\x27]'), '') // Remove HTML/JS characters
        .replaceAll(
            RegExp(r'[\x00-\x1F\x7F]'), ''); // Remove control characters
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult({
    required this.isValid,
    required this.message,
  });
}
