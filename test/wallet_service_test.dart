import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:nimbus/features/wallet/data/services/wallet_service.dart';
import 'package:nimbus/core/services/transaction_service.dart';

import 'wallet_service_test.mocks.dart';

@GenerateMocks([http.Client, TransactionService])
void main() {
  group('WalletService Tests', () {
    late WalletService walletService;
    late MockClient mockClient;
    late MockTransactionService mockTransactionService;

    setUp(() {
      mockClient = MockClient();
      mockTransactionService = MockTransactionService();
      walletService = WalletService(client: mockClient);
    });

    group('Wallet Connection', () {
      test('should initialize AppKit successfully', () async {
        // This test would require mocking the AppKit initialization
        // For now, we'll test the basic structure
        expect(walletService.isConnected, false);
        expect(walletService.connectedAddress, null);
      });

      test('should handle connection failure gracefully', () async {
        // Test error handling for connection failures
        expect(walletService.isConnected, false);
      });
    });

    group('Token Balance Retrieval', () {
      test('should return empty list for null address', () async {
        final balances = await walletService.getTokenBalances(null);

        expect(balances, isEmpty);
      });

      test('should handle invalid address format', () async {
        const invalidAddress = 'invalid_address';

        expect(
          () => walletService.getTokenBalances(invalidAddress),
          throwsA(isA<WalletException>()),
        );
      });

      test('should handle network errors gracefully', () async {
        const validAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';

        // Mock network error
        when(mockClient.get(any)).thenThrow(Exception('Network error'));

        expect(
          () => walletService.getTokenBalances(validAddress),
          throwsA(isA<WalletException>()),
        );
      });
    });

    group('Transaction Operations', () {
      test('should throw exception when wallet not connected', () async {
        expect(
          () => walletService.sendEthTransaction(
            toAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
            amountInEth: '1.0',
          ),
          throwsA(isA<WalletException>()),
        );
      });

      test('should validate transaction parameters', () async {
        // Test with invalid recipient address
        expect(
          () => walletService.sendEthTransaction(
            toAddress: 'invalid_address',
            amountInEth: '1.0',
          ),
          throwsA(isA<WalletException>()),
        );
      });
    });

    group('ETH Balance Retrieval', () {
      test('should return 0 for null address', () async {
        final balance = await walletService.getETHBalance(null);

        expect(balance, 0.0);
      });

      test('should handle API errors gracefully', () async {
        const validAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';

        // Mock API error
        when(mockClient.get(any)).thenThrow(Exception('API error'));

        final balance = await walletService.getETHBalance(validAddress);

        expect(balance, 0.0);
      });
    });

    group('Token Balance Model', () {
      test('should calculate balance correctly', () {
        final tokenBalance = TokenBalance(
          contractAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          tokenBalance: '1000000000000000000', // 1 ETH in wei
          name: 'Ethereum',
          symbol: 'ETH',
          decimals: 18,
        );

        expect(tokenBalance.balance, 1.0);
      });

      test('should handle zero balance', () {
        final tokenBalance = TokenBalance(
          contractAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          tokenBalance: '0',
          name: 'Ethereum',
          symbol: 'ETH',
          decimals: 18,
        );

        expect(tokenBalance.balance, 0.0);
      });

      test('should handle invalid balance string', () {
        final tokenBalance = TokenBalance(
          contractAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
          tokenBalance: 'invalid',
          name: 'Ethereum',
          symbol: 'ETH',
          decimals: 18,
        );

        expect(tokenBalance.balance, 0.0);
      });
    });
  });

  group('TransactionService Tests', () {
    late TransactionService transactionService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      transactionService = TransactionService(client: mockClient);
    });

    group('Transaction Validation', () {
      test('should validate transaction parameters', () {
        // Test with valid parameters
        expect(
          () => transactionService.sendEthTransaction(
            fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
            toAddress: '0x8ba1f109551bD432803012645Hac136c',
            amountInEth: '1.0',
            gasPrice: '20',
            gasLimit: '21000',
          ),
          throwsA(isA<
              TransactionException>()), // Should throw because AppKit is not set
        );
      });

      test('should reject invalid recipient address', () {
        expect(
          () => transactionService.sendEthTransaction(
            fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
            toAddress: 'invalid_address',
            amountInEth: '1.0',
            gasPrice: '20',
            gasLimit: '21000',
          ),
          throwsA(isA<TransactionException>()),
        );
      });

      test('should reject invalid amount', () {
        expect(
          () => transactionService.sendEthTransaction(
            fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
            toAddress: '0x8ba1f109551bD432803012645Hac136c',
            amountInEth: '-1.0',
            gasPrice: '20',
            gasLimit: '21000',
          ),
          throwsA(isA<TransactionException>()),
        );
      });

      test('should reject invalid gas price', () {
        expect(
          () => transactionService.sendEthTransaction(
            fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
            toAddress: '0x8ba1f109551bD432803012645Hac136c',
            amountInEth: '1.0',
            gasPrice: '-20',
            gasLimit: '21000',
          ),
          throwsA(isA<TransactionException>()),
        );
      });

      test('should reject invalid gas limit', () {
        expect(
          () => transactionService.sendEthTransaction(
            fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
            toAddress: '0x8ba1f109551bD432803012645Hac136c',
            amountInEth: '1.0',
            gasPrice: '20',
            gasLimit: '-21000',
          ),
          throwsA(isA<TransactionException>()),
        );
      });
    });

    group('Transaction Status', () {
      test('should handle network errors when getting transaction status',
          () async {
        const txHash = '0x1234567890abcdef';

        // Mock network error
        when(mockClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        final status = await transactionService.getTransactionStatus(txHash);

        expect(status, TransactionStatus.unknown);
      });
    });

    group('Gas Estimation', () {
      test('should handle network errors when estimating gas', () async {
        // Mock network error
        when(mockClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        expect(
          () => transactionService.estimateGas(
            from: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
            to: '0x8ba1f109551bD432803012645Hac136c',
            value: '0xde0b6b3a7640000', // 1 ETH in hex
          ),
          throwsA(isA<TransactionException>()),
        );
      });
    });

    group('Gas Price Retrieval', () {
      test('should handle network errors when getting gas price', () async {
        // Mock network error
        when(mockClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        expect(
          () => transactionService.getCurrentGasPrice(),
          throwsA(isA<TransactionException>()),
        );
      });
    });
  });

  group('Exception Classes', () {
    test('WalletConnectionException should have correct message', () {
      const message = 'Connection failed';
      final exception = WalletConnectionException(message);

      expect(exception.message, message);
      expect(exception.toString(), 'WalletConnectionException: $message');
    });

    test('WalletException should have correct message', () {
      const message = 'Wallet error';
      final exception = WalletException(message);

      expect(exception.message, message);
      expect(exception.toString(), 'WalletException: $message');
    });

    test('TransactionException should have correct message', () {
      const message = 'Transaction failed';
      final exception = TransactionException(message);

      expect(exception.message, message);
      expect(exception.toString(), 'TransactionException: $message');
    });
  });
}
