import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/payment_provider_service.dart';

class PaymentProviderState {
  final List<PaymentProvider> providers;
  final bool isLoading;
  final String? error;
  final Map<String, Map<String, dynamic>> providerStatus;
  final DateTime lastUpdated;

  const PaymentProviderState({
    this.providers = const [],
    this.isLoading = false,
    this.error,
    this.providerStatus = const {},
    required this.lastUpdated,
  });

  PaymentProviderState copyWith({
    List<PaymentProvider>? providers,
    bool? isLoading,
    String? error,
    Map<String, Map<String, dynamic>>? providerStatus,
    DateTime? lastUpdated,
  }) {
    return PaymentProviderState(
      providers: providers ?? this.providers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      providerStatus: providerStatus ?? this.providerStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class PaymentProviderNotifier extends StateNotifier<PaymentProviderState> {
  PaymentProviderNotifier()
      : super(PaymentProviderState(lastUpdated: DateTime.now())) {
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final providers = await PaymentProviderService.getAvailableProviders();
      final statusMap = <String, Map<String, dynamic>>{};

      // Get status for each provider
      for (final provider in providers) {
        final status =
            await PaymentProviderService.getProviderStatus(provider.name);
        statusMap[provider.name] = status;
      }

      state = state.copyWith(
        providers: providers,
        isLoading: false,
        providerStatus: statusMap,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshProviders() async {
    await _loadProviders();
  }

  Future<bool> launchPaymentProvider({
    required String providerName,
    required String cryptoAsset,
    required String cryptoAmount,
    required String fiatAmount,
    required String fiatCurrency,
    required String walletAddress,
  }) async {
    // This will be called from the UI with BuildContext
    // The actual launch logic is in PaymentProviderService
    return true;
  }

  PaymentProvider? getProvider(String name) {
    return PaymentProviderService.getProvider(name);
  }
}

final paymentProviderNotifier =
    StateNotifierProvider<PaymentProviderNotifier, PaymentProviderState>((ref) {
  return PaymentProviderNotifier();
});

final paymentProvidersProvider = Provider<List<PaymentProvider>>((ref) {
  return ref.watch(paymentProviderNotifier).providers;
});

final paymentProviderStatusProvider =
    Provider<Map<String, Map<String, dynamic>>>((ref) {
  return ref.watch(paymentProviderNotifier).providerStatus;
});
