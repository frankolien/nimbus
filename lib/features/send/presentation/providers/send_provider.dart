import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'send_provider.g.dart';

enum SendStep {
  addressInput,
  amountInput,
  confirmation,
}

class SendStateData {
  final SendStep currentStep;
  final String recipientAddress;
  final String recipientName;
  final String amount;
  final double solBalance;
  final double usdAmount;
  final String? errorMessage;

  const SendStateData({
    this.currentStep = SendStep.addressInput,
    this.recipientAddress = '',
    this.recipientName = '',
    this.amount = '',
    this.solBalance = 329.27,
    this.usdAmount = 0.0,
    this.errorMessage,
  });

  SendStateData copyWith({
    SendStep? currentStep,
    String? recipientAddress,
    String? recipientName,
    String? amount,
    double? solBalance,
    double? usdAmount,
    String? errorMessage,
  }) {
    return SendStateData(
      currentStep: currentStep ?? this.currentStep,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      solBalance: solBalance ?? this.solBalance,
      usdAmount: usdAmount ?? this.usdAmount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class SendNotifier extends _$SendNotifier {
  @override
  SendStateData build() {
    return const SendStateData();
  }

  void updateRecipientAddress(String address) {
    state = state.copyWith(
      recipientAddress: address,
      errorMessage: null,
    );
  }

  void updateRecipientName(String name) {
    state = state.copyWith(recipientName: name);
  }

  void updateAmount(String amount) {
    final usdAmount = _calculateUsdAmount(amount);
    state = state.copyWith(
      amount: amount,
      usdAmount: usdAmount,
      errorMessage: null,
    );
  }

  void setMaxAmount() {
    final maxAmount = state.solBalance.toStringAsFixed(2);
    final usdAmount = _calculateUsdAmount(maxAmount);
    state = state.copyWith(
      amount: maxAmount,
      usdAmount: usdAmount,
    );
  }

  void nextStep() {
    switch (state.currentStep) {
      case SendStep.addressInput:
        if (state.recipientAddress.isNotEmpty) {
          state = state.copyWith(currentStep: SendStep.amountInput);
        }
        break;
      case SendStep.amountInput:
        if (state.amount.isNotEmpty && double.tryParse(state.amount) != null) {
          state = state.copyWith(currentStep: SendStep.confirmation);
        }
        break;
      case SendStep.confirmation:
        // Handle final confirmation
        break;
    }
  }

  void previousStep() {
    switch (state.currentStep) {
      case SendStep.addressInput:
        // Already at first step
        break;
      case SendStep.amountInput:
        state = state.copyWith(currentStep: SendStep.addressInput);
        break;
      case SendStep.confirmation:
        state = state.copyWith(currentStep: SendStep.amountInput);
        break;
    }
  }

  void setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  bool get canProceed {
    switch (state.currentStep) {
      case SendStep.addressInput:
        return state.recipientAddress.isNotEmpty;
      case SendStep.amountInput:
        return state.amount.isNotEmpty &&
            double.tryParse(state.amount) != null &&
            double.parse(state.amount) > 0 &&
            double.parse(state.amount) <= state.solBalance;
      case SendStep.confirmation:
        return true;
    }
  }

  bool canProceedForStep(SendStep step) {
    switch (step) {
      case SendStep.addressInput:
        return state.recipientAddress.isNotEmpty;
      case SendStep.amountInput:
        return state.amount.isNotEmpty &&
            double.tryParse(state.amount) != null &&
            double.parse(state.amount) > 0 &&
            double.parse(state.amount) <= state.solBalance;
      case SendStep.confirmation:
        return true;
    }
  }

  double _calculateUsdAmount(String solAmount) {
    final sol = double.tryParse(solAmount) ?? 0.0;
    // SOL price is approximately $138.52 based on the mockup
    return sol * 138.52;
  }
}
