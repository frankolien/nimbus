import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/crypto_asset.dart';
import '../../domain/entities/payment_method.dart';

part 'buy_provider.g.dart';

@riverpod
class BuyNotifier extends _$BuyNotifier {
  @override
  BuyStateData build() {
    // Start with a default asset, will be updated with real-time prices
    return const BuyStateData(
      selectedAsset: CryptoAsset(
        symbol: 'BTC',
        name: 'Bitcoin',
        iconPath: 'assets/images/bitcoin.png',
        category: 'cryptocurrency',
        price: 0.0, // Will be updated with real-time price
        balance: 0.0,
      ),
    );
  }

  void updateAmount(String amount) {
    state = state.copyWith(usdAmount: amount);
  }

  void selectAsset(CryptoAsset asset) {
    state = state.copyWith(selectedAsset: asset);
  }

  void selectPaymentMethod(PaymentMethod paymentMethod) {
    state = state.copyWith(selectedPaymentMethod: paymentMethod);
  }

  void toggleAssetSelectionModal() {
    state =
        state.copyWith(showAssetSelectionModal: !state.showAssetSelectionModal);
  }

  void togglePaymentMethodModal() {
    state =
        state.copyWith(showPaymentMethodModal: !state.showPaymentMethodModal);
  }

  void clearAmount() {
    state = state.copyWith(usdAmount: '0');
  }

  void addDigit(String digit) {
    String newAmount = state.usdAmount == '0' ? digit : state.usdAmount + digit;
    state = state.copyWith(usdAmount: newAmount);
  }

  void removeLastDigit() {
    if (state.usdAmount.length > 1) {
      state = state.copyWith(
          usdAmount: state.usdAmount.substring(0, state.usdAmount.length - 1));
    } else {
      state = state.copyWith(usdAmount: '0');
    }
  }
}

class BuyStateData {
  final String usdAmount;
  final CryptoAsset? selectedAsset;
  final PaymentMethod? selectedPaymentMethod;
  final bool showAssetSelectionModal;
  final bool showPaymentMethodModal;

  const BuyStateData({
    this.usdAmount = '0',
    this.selectedAsset,
    this.selectedPaymentMethod,
    this.showAssetSelectionModal = false,
    this.showPaymentMethodModal = false,
  });

  BuyStateData copyWith({
    String? usdAmount,
    CryptoAsset? selectedAsset,
    PaymentMethod? selectedPaymentMethod,
    bool? showAssetSelectionModal,
    bool? showPaymentMethodModal,
  }) {
    return BuyStateData(
      usdAmount: usdAmount ?? this.usdAmount,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      showAssetSelectionModal:
          showAssetSelectionModal ?? this.showAssetSelectionModal,
      showPaymentMethodModal:
          showPaymentMethodModal ?? this.showPaymentMethodModal,
    );
  }

  double get cryptoAmount {
    if (selectedAsset == null) return 0.0;
    return (double.tryParse(usdAmount) ?? 0.0) / selectedAsset!.price;
  }

  bool get canProceedToPayment {
    return usdAmount != '0' &&
        double.tryParse(usdAmount) != null &&
        double.parse(usdAmount) > 0 &&
        selectedAsset != null;
  }

  bool get canConfirm {
    return usdAmount != '0' &&
        double.tryParse(usdAmount) != null &&
        double.parse(usdAmount) > 0 &&
        selectedAsset != null &&
        selectedPaymentMethod != null;
  }
}
