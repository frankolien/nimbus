import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/withdraw_provider.dart';
import '../widgets/withdraw_asset_selection_screen.dart';
import '../widgets/withdraw_amount_input_screen.dart';
import '../widgets/withdraw_confirmation_screen.dart';

class WithdrawPage extends ConsumerStatefulWidget {
  const WithdrawPage({super.key});

  @override
  ConsumerState<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends ConsumerState<WithdrawPage> {
  @override
  Widget build(BuildContext context) {
    final withdrawState = ref.watch(withdrawNotifierProvider);
    final withdrawNotifier = ref.read(withdrawNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (withdrawState.currentStep == WithdrawStep.assetSelection) {
              Navigator.of(context).pop();
            } else {
              withdrawNotifier.previousStep();
            }
          },
        ),
        title: Text(
          _getAppBarTitle(withdrawState.currentStep),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: _getCurrentScreen(withdrawState.currentStep),
    );
  }

  Widget _getCurrentScreen(WithdrawStep step) {
    switch (step) {
      case WithdrawStep.assetSelection:
        return const WithdrawAssetSelectionScreen();
      case WithdrawStep.amountInput:
        return const WithdrawAmountInputScreen();
      case WithdrawStep.confirmation:
        return const WithdrawConfirmationScreen();
    }
  }

  String _getAppBarTitle(WithdrawStep step) {
    switch (step) {
      case WithdrawStep.assetSelection:
        return 'Withdraw crypto';
      case WithdrawStep.amountInput:
        return 'Withdraw amount';
      case WithdrawStep.confirmation:
        return 'Confirm withdrawal';
    }
  }

  void _refreshData() {
    ref.invalidate(withdrawNotifierProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
