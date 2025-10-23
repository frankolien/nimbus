import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/buy_provider.dart';
import '../widgets/asset_selection_modal.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/payment_method_modal.dart';

class BuyPage extends ConsumerWidget {
  const BuyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      const SizedBox(height: 24),

                      // Payment Method Card
                      _buildPaymentMethodCard(buyState, buyNotifier),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.usdAmount} USD',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.selectedAsset != null
                        ? '${state.cryptoAmount.toStringAsFixed(6)} ${state.selectedAsset!.symbol}'
                        : '0.000000 SOL',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
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

  Widget _buildPaymentMethodCard(BuyStateData state, BuyNotifier notifier) {
    return GestureDetector(
      onTap: notifier.togglePaymentMethodModal,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            // Payment Method Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF444444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.payment,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Payment Method Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedPaymentMethod?.name ??
                        'Choose payment method',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    state.selectedPaymentMethod?.description ??
                        'Select how you want to pay',
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
      ),
    );
  }

  Widget _buildConfirmButton(
      BuyStateData state, BuyNotifier notifier, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: state.canConfirm
            ? () {
                // TODO: Implement buy confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buy order placed successfully!'),
                    backgroundColor: Color(0xFFFF6B35),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: state.canConfirm
              ? const Color(0xFFFF6B35)
              : const Color(0xFF444444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Confirm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
