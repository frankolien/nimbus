import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nimbus/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:nimbus/shared/services/blockchain_balance_service.dart';

part 'receive_provider.g.dart';

enum ReceiveStep {
  assetSelection,
  qrCode,
  requestAmount,
  amountQR,
}

class ReceiveStateData {
  final ReceiveStep currentStep;
  final String selectedAsset;
  final String requestAmount;
  final String requestCurrency;
  final String? walletAddress;
  final Map<String, double>? realBalances;
  final String? errorMessage;

  const ReceiveStateData({
    this.currentStep = ReceiveStep.assetSelection,
    this.selectedAsset = 'SOL',
    this.requestAmount = '',
    this.requestCurrency = 'USD',
    this.walletAddress,
    this.realBalances,
    this.errorMessage,
  });

  ReceiveStateData copyWith({
    ReceiveStep? currentStep,
    String? selectedAsset,
    String? requestAmount,
    String? requestCurrency,
    String? walletAddress,
    Map<String, double>? realBalances,
    String? errorMessage,
  }) {
    return ReceiveStateData(
      currentStep: currentStep ?? this.currentStep,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      requestAmount: requestAmount ?? this.requestAmount,
      requestCurrency: requestCurrency ?? this.requestCurrency,
      walletAddress: walletAddress ?? this.walletAddress,
      realBalances: realBalances ?? this.realBalances,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class ReceiveNotifier extends _$ReceiveNotifier {
  @override
  ReceiveStateData build() {
    // Load real wallet address and balances
    _loadRealData();
    return const ReceiveStateData();
  }

  Future<void> _loadRealData() async {
    try {
      final walletAddress = ref.read(currentWalletAddressProvider);

      if (walletAddress != null) {
        // Load real balances
        final balances =
            await BlockchainBalanceService.getAllBalances(walletAddress);
        state = state.copyWith(
          walletAddress: walletAddress,
          realBalances: balances,
        );
      }
    } catch (e) {
      print('Error loading receive data: $e');
    }
  }

  void selectAsset(String asset) {
    state = state.copyWith(
      selectedAsset: asset,
      errorMessage: null,
    );
  }

  void updateRequestAmount(String amount) {
    state = state.copyWith(
      requestAmount: amount,
      errorMessage: null,
    );
  }

  void updateRequestCurrency(String currency) {
    state = state.copyWith(requestCurrency: currency);
  }

  void nextStep() {
    switch (state.currentStep) {
      case ReceiveStep.assetSelection:
        state = state.copyWith(currentStep: ReceiveStep.qrCode);
        break;
      case ReceiveStep.qrCode:
        // Can go to request amount or stay on QR
        break;
      case ReceiveStep.requestAmount:
        if (state.requestAmount.isNotEmpty) {
          state = state.copyWith(currentStep: ReceiveStep.amountQR);
        }
        break;
      case ReceiveStep.amountQR:
        // Final step
        break;
    }
  }

  void previousStep() {
    switch (state.currentStep) {
      case ReceiveStep.assetSelection:
        // Already at first step
        break;
      case ReceiveStep.qrCode:
        state = state.copyWith(currentStep: ReceiveStep.assetSelection);
        break;
      case ReceiveStep.requestAmount:
        state = state.copyWith(currentStep: ReceiveStep.qrCode);
        break;
      case ReceiveStep.amountQR:
        state = state.copyWith(currentStep: ReceiveStep.requestAmount);
        break;
    }
  }

  void goToRequestAmount() {
    state = state.copyWith(currentStep: ReceiveStep.requestAmount);
  }

  void setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  bool get canProceedToAmount {
    return state.requestAmount.isNotEmpty &&
        double.tryParse(state.requestAmount) != null &&
        double.parse(state.requestAmount) > 0;
  }
}
