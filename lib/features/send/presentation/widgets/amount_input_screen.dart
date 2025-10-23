import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/send_provider.dart';
import '../../../../shared/services/crypto_price_service.dart';

class AmountInputScreen extends ConsumerStatefulWidget {
  const AmountInputScreen({super.key});

  @override
  ConsumerState<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends ConsumerState<AmountInputScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sync controller with initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sendState = ref.read(sendNotifierProvider);
      if (sendState.amount.isNotEmpty) {
        _amountController.text = sendState.amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendNotifierProvider);
    final sendNotifier = ref.read(sendNotifierProvider.notifier);

    // Watch for crypto price changes and update USD amount
    ref.listen<AsyncValue<List<CryptoPrice>>>(cryptoPricesRefreshProvider,
        (previous, next) {
      if (next.hasValue && sendState.amount.isNotEmpty) {
        // Recalculate USD amount when prices change
        sendNotifier.updateAmount(sendState.amount);
      }
    });

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipient Info
                _buildRecipientInfo(sendState),

                const SizedBox(height: 24),

                // Available Balance
                _buildAvailableBalance(sendState, sendNotifier),

                const SizedBox(height: 24),

                // Amount Input Field
                _buildAmountInputField(sendState, sendNotifier),

                const SizedBox(height: 24), // Extra padding at bottom
              ],
            ),
          ),
        ),

        // Fixed Confirm Button
        Container(
          padding: const EdgeInsets.all(16.0),
          child: _buildConfirmButton(sendState, sendNotifier),
        ),
      ],
    );
  }

  Widget _buildRecipientInfo(SendStateData state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Text(
            state.recipientAddress,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableBalance(SendStateData state, SendNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Available Balance',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Text(
              '${state.solBalance.toStringAsFixed(2)} SOL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => notifier.setMaxAmount(),
              child: const Text(
                'Max',
                style: TextStyle(color: Color(0xFFFF6B35)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountInputField(SendStateData state, SendNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            TextFormField(
              controller: _amountController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 32,
                ),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                notifier.updateAmount(value);
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'SOL',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '\$${state.usdAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmButton(SendStateData state, SendNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: notifier.canProceedForStep(SendStep.amountInput)
            ? () => notifier.nextStep()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: notifier.canProceedForStep(SendStep.amountInput)
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
