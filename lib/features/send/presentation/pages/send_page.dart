import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/send_provider.dart';
import '../widgets/address_input_screen.dart';
import '../widgets/amount_input_screen.dart';
import '../widgets/confirmation_screen.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendNotifierProvider);

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
          'Send SOL',
          style: TextStyle(
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
      body: _getCurrentScreen(sendState.currentStep),
    );
  }

  Widget _getCurrentScreen(SendStep step) {
    switch (step) {
      case SendStep.addressInput:
        return const AddressInputScreen();
      case SendStep.amountInput:
        return const AmountInputScreen();
      case SendStep.confirmation:
        return const ConfirmationScreen();
    }
  }

  void _refreshData() {
    // Refresh wallet data and balances
    ref.invalidate(sendNotifierProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
