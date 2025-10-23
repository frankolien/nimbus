import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/buy_provider.dart';
import '../widgets/asset_selection_modal.dart';
import '../widgets/payment_method_modal.dart';
import 'payment_method_selection_screen.dart';
import '../../../../shared/services/crypto_price_service.dart';

class BuyPage extends ConsumerStatefulWidget {
  const BuyPage({super.key});

  @override
  ConsumerState<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends ConsumerState<BuyPage> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with current amount
    final buyState = ref.read(buyNotifierProvider);
    _amountController.text = buyState.usdAmount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buyState = ref.watch(buyNotifierProvider);
    final buyNotifier = ref.read(buyNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Buy crypto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _refreshPrices(),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                      ),
                      // Amount Display Section
                      _buildAmountSection(buyState, buyNotifier),
                      const SizedBox(height: 48),
                      Divider(),
                      SizedBox(
                        height: 24,
                      ),
                      // Asset Selection Card
                      _buildAssetSelectionCard(buyState, buyNotifier),
                    ],
                  ),
                ),
              ),

              // Numeric Keypad
              /*NumericKeypad(
                onDigitPressed: buyNotifier.addDigit,
                onBackspacePressed: buyNotifier.removeLastDigit,
                onClearPressed: buyNotifier.clearAmount,
              ),*/

              // Confirm Button
              _buildConfirmButton(buyState, buyNotifier, context),
            ],
          ),

          // Modals
          if (buyState.showAssetSelectionModal)
            AssetSelectionModal(
              onAssetSelected: buyNotifier.selectAsset,
              onClose: buyNotifier.toggleAssetSelectionModal,
            ),

          if (buyState.showPaymentMethodModal)
            PaymentMethodModal(
              onPaymentMethodSelected: buyNotifier.selectPaymentMethod,
              onClose: buyNotifier.togglePaymentMethodModal,
            ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuyStateData state, BuyNotifier notifier) {
    return Column(
      children: [
        // USD Amount Input Field
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(
              color: Color(0xFF666666),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            suffixText: 'USD',
            suffixStyle: TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: Colors.black,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            // Update the amount when user types
            notifier.updateAmount(value.isEmpty ? '0' : value);
          },
        ),
        const SizedBox(height: 8),
        // Crypto Amount Display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${state.cryptoAmount.toStringAsFixed(6)} ${state.selectedAsset?.symbol ?? 'SOL'}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.swap_vert,
                color: Colors.white70,
                size: 24,
              ),
              onPressed: () {
                // TODO: Implement currency swap
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetSelectionCard(BuyStateData state, BuyNotifier notifier) {
    return GestureDetector(
      onTap: notifier.toggleAssetSelectionModal,
      child: Row(
        children: [
          // Asset Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.currency_bitcoin,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Asset Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedAsset?.symbol ?? 'SOL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  state.selectedAsset?.name ?? 'Solana',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Arrow Icon
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(
      BuyStateData state, BuyNotifier notifier, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: state.canProceedToPayment
            ? () {
                // Navigate to payment method selection screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodSelectionScreen(
                      usdAmount: state.usdAmount,
                      selectedAsset: state.selectedAsset!,
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: state.canProceedToPayment
              ? const Color(0xFFFF6B35)
              : const Color(0xFF444444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _refreshPrices() {
    // Refresh crypto prices
    ref.invalidate(cryptoPricesProvider);

    // Show refresh feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing prices...'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
