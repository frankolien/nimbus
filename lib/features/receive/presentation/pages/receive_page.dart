import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/receive_provider.dart';
import '../widgets/asset_selection_screen.dart';
import '../widgets/qr_code_screen.dart';
import '../widgets/request_amount_screen.dart';
import '../widgets/amount_qr_screen.dart';

class ReceivePage extends ConsumerStatefulWidget {
  const ReceivePage({super.key});

  @override
  ConsumerState<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends ConsumerState<ReceivePage> {
  @override
  Widget build(BuildContext context) {
    final receiveState = ref.watch(receiveNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _getAppBarTitle(receiveState.currentStep),
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
      body: _getCurrentScreen(receiveState.currentStep),
    );
  }

  Widget _getCurrentScreen(ReceiveStep step) {
    switch (step) {
      case ReceiveStep.assetSelection:
        return const AssetSelectionScreen();
      case ReceiveStep.qrCode:
        return const QRCodeScreen();
      case ReceiveStep.requestAmount:
        return const RequestAmountScreen();
      case ReceiveStep.amountQR:
        return const AmountQRScreen();
    }
  }

  String _getAppBarTitle(ReceiveStep step) {
    switch (step) {
      case ReceiveStep.assetSelection:
        return 'Receive crypto';
      case ReceiveStep.qrCode:
        return 'Receive';
      case ReceiveStep.requestAmount:
        return 'Request crypto';
      case ReceiveStep.amountQR:
        return 'Receive';
    }
  }

  void _refreshData() {
    ref.invalidate(receiveNotifierProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
