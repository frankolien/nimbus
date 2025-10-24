import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Comprehensive error handling service
/// Provides centralized error handling, logging, and user-friendly error messages
class ErrorHandler {
  static const String _logTag = 'NimbusError';

  /// Handle and log errors with context
  static void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
    bool showToUser = true,
  }) {
    // Log error details
    _logError(error, stackTrace, context, additionalData);

    // Show user-friendly error if needed
    if (showToUser) {
      _showUserError(error, context);
    }
  }

  /// Log error with full context
  static void _logError(
    dynamic error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    final errorMessage = error.toString();
    final contextInfo = context != null ? 'Context: $context' : '';
    final additionalInfo =
        additionalData != null ? 'Additional: $additionalData' : '';

    if (kDebugMode) {
      print('❌ $_logTag: $errorMessage');
      if (contextInfo.isNotEmpty) print('📍 $_logTag: $contextInfo');
      if (additionalInfo.isNotEmpty) print('📊 $_logTag: $additionalInfo');
      if (stackTrace != null) print('📚 $_logTag: $stackTrace');
    }

    // In production, you would send this to a logging service
    // like Sentry, Crashlytics, or your own logging API
    _sendToLoggingService(error, stackTrace, context, additionalData);
  }

  /// Send error to logging service (implement based on your needs)
  static void _sendToLoggingService(
    dynamic error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    // TODO: Implement logging service integration
    // Examples:
    // - Sentry.captureException(error, stackTrace: stackTrace)
    // - FirebaseCrashlytics.instance.recordError(error, stackTrace)
    // - Custom API call to your logging service
  }

  /// Show user-friendly error message
  static void _showUserError(dynamic error, String? context) {
    // Get the current context
    final context = _getCurrentContext();
    if (context == null) return;

    final errorMessage = _getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Get user-friendly error message
  static String _getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('handshakeexception') ||
        errorString.contains('timeout')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    // Wallet connection errors
    if (errorString.contains('walletconnectionexception')) {
      return 'Failed to connect wallet. Please try again.';
    }

    // Transaction errors
    if (errorString.contains('transactionexception')) {
      if (errorString.contains('rejected')) {
        return 'Transaction was cancelled by user.';
      } else if (errorString.contains('insufficient')) {
        return 'Insufficient funds for this transaction.';
      } else if (errorString.contains('gas')) {
        return 'Transaction failed due to gas issues. Please try again.';
      } else {
        return 'Transaction failed. Please try again.';
      }
    }

    // Security errors
    if (errorString.contains('securityexception')) {
      return 'Security error occurred. Please try again.';
    }

    // Validation errors
    if (errorString.contains('validation')) {
      return 'Invalid input. Please check your data and try again.';
    }

    // Generic error
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get current BuildContext (this is a simplified approach)
  static BuildContext? _getCurrentContext() {
    // In a real implementation, you'd use a global navigator key
    // or pass the context explicitly
    return null;
  }

  /// Handle async errors in a try-catch block
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? context,
    Map<String, dynamic>? additionalData,
    bool showToUser = true,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace,
        context: context,
        additionalData: additionalData,
        showToUser: showToUser,
      );
      return fallbackValue;
    }
  }

  /// Handle sync errors in a try-catch block
  static T? handleSync<T>(
    T Function() operation, {
    String? context,
    Map<String, dynamic>? additionalData,
    bool showToUser = true,
    T? fallbackValue,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace,
        context: context,
        additionalData: additionalData,
        showToUser: showToUser,
      );
      return fallbackValue;
    }
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog with error handling
  static Future<T?> showLoadingDialog<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    String? errorTitle,
    String? errorMessage,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(loadingMessage ?? 'Loading...'),
          ],
        ),
      ),
    );

    try {
      final result = await operation();
      Navigator.of(context).pop(); // Close loading dialog
      return result;
    } catch (error, stackTrace) {
      Navigator.of(context).pop(); // Close loading dialog

      handleError(
        error,
        stackTrace,
        context: 'Loading dialog operation',
        showToUser: false, // We'll show our own dialog
      );

      showErrorDialog(
        context,
        errorTitle ?? 'Error',
        errorMessage ?? _getUserFriendlyMessage(error),
      );

      return null;
    }
  }

  /// Validate and handle API responses
  static void handleApiResponse(
    dynamic response, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    if (response == null) {
      handleError(
        'API response is null',
        null,
        context: context ?? 'API Response',
        additionalData: additionalData,
      );
      return;
    }

    // Check for common API error patterns
    if (response is Map<String, dynamic>) {
      if (response.containsKey('error')) {
        handleError(
          response['error'],
          null,
          context: context ?? 'API Error',
          additionalData: additionalData,
        );
      }
    }
  }

  /// Handle network timeouts
  static Future<T?> handleTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    String? context,
    T? fallbackValue,
  }) async {
    try {
      return await operation().timeout(timeout);
    } catch (error) {
      if (error.toString().contains('timeout')) {
        handleError(
          'Operation timed out after ${timeout.inSeconds} seconds',
          null,
          context: context ?? 'Timeout',
          additionalData: {'timeout_duration': timeout.inSeconds},
        );
      } else {
        handleError(error, null, context: context);
      }
      return fallbackValue;
    }
  }
}
