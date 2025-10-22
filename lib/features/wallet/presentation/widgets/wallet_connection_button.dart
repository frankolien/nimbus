import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

class WalletConnectionButton extends StatelessWidget {
  final ReownAppKitModal appKitModal;

  const WalletConnectionButton({
    super.key,
    required this.appKitModal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Network selection button
        AppKitModalNetworkSelectButton(appKit: appKitModal),

        const SizedBox(height: 16),

        // Connect/Disconnect button
        AppKitModalConnectButton(appKit: appKitModal),

        const SizedBox(height: 16),

        // Account button (only visible when connected)
        Visibility(
          visible: appKitModal.isConnected,
          child: AppKitModalAccountButton(appKitModal: appKitModal),
        ),

        const SizedBox(height: 16),

        // Custom balance and address buttons
        if (appKitModal.isConnected) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: AppKitModalBalanceButton(
                  appKitModal: appKitModal,
                  onTap: () => appKitModal.openModalView(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppKitModalAddressButton(
                  appKitModal: appKitModal,
                  onTap: () => appKitModal.openModalView(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Custom wallet connection button
class CustomWalletButton extends StatelessWidget {
  final ReownAppKitModal appKitModal;
  final String text;
  final VoidCallback? onPressed;

  const CustomWalletButton({
    super.key,
    required this.appKitModal,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () => appKitModal.openModalView(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}
