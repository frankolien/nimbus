import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'withdraw_provider.g.dart';

enum WithdrawStep {
  assetSelection,
  amountInput,
  confirmation,
}

class WithdrawStateData {
  final WithdrawStep currentStep;
  final String selectedAsset;
  final String amount;
  final String currency;
  final String recipientAddress;
  final String? errorMessage;

  const WithdrawStateData({
    this.currentStep = WithdrawStep.assetSelection,
    this.selectedAsset = 'SOL',
    this.amount = '',
    this.currency = 'USD',
    this.recipientAddress = '',
    this.errorMessage,
  });

  WithdrawStateData copyWith({
    WithdrawStep? currentStep,
    String? selectedAsset,
    String? amount,
    String? currency,
    String? recipientAddress,
    String? errorMessage,
  }) {
    return WithdrawStateData(
      currentStep: currentStep ?? this.currentStep,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class WithdrawNotifier extends _$WithdrawNotifier {
  @override
  WithdrawStateData build() {
    return const WithdrawStateData();
  }

  void selectAsset(String asset) {
    state = state.copyWith(
      selectedAsset: asset,
      errorMessage: null,
    );
  }

  void updateAmount(String amount) {
    state = state.copyWith(
      amount: amount,
      errorMessage: null,
    );
  }

  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  void updateRecipientAddress(String address) {
    state = state.copyWith(
      recipientAddress: address,
      errorMessage: null,
    );
  }

  void nextStep() {
    switch (state.currentStep) {
      case WithdrawStep.assetSelection:
        state = state.copyWith(currentStep: WithdrawStep.amountInput);
        break;
      case WithdrawStep.amountInput:
        if (canProceedToConfirmation) {
          state = state.copyWith(currentStep: WithdrawStep.confirmation);
        }
        break;
      case WithdrawStep.confirmation:
        // Final step - execute withdrawal
        break;
    }
  }

  void previousStep() {
    switch (state.currentStep) {
      case WithdrawStep.assetSelection:
        // Already at first step
        break;
      case WithdrawStep.amountInput:
        state = state.copyWith(currentStep: WithdrawStep.assetSelection);
        break;
      case WithdrawStep.confirmation:
        state = state.copyWith(currentStep: WithdrawStep.amountInput);
        break;
    }
  }

  void executeWithdrawal() {
    // TODO: Implement actual withdrawal logic
    // For now, just show success
    state = state.copyWith(errorMessage: 'Withdrawal successful!');
  }

  void setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  bool get canProceedToAmount {
    return state.selectedAsset.isNotEmpty;
  }

  bool get canProceedToConfirmation {
    return state.amount.isNotEmpty &&
        double.tryParse(state.amount) != null &&
        double.parse(state.amount) > 0 &&
        state.recipientAddress.isNotEmpty;
  }

  bool get canExecuteWithdrawal {
    return canProceedToConfirmation;
  }
}
