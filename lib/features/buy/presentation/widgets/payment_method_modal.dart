import 'package:flutter/material.dart';

import '../../domain/entities/payment_method.dart';

class PaymentMethodModal extends StatelessWidget {
  final Function(PaymentMethod) onPaymentMethodSelected;
  final VoidCallback onClose;

  const PaymentMethodModal({
    super.key,
    required this.onPaymentMethodSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),

              // Payment Methods List
              _buildPaymentMethodsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF333333)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Choose payment method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    final paymentMethods = _getMockPaymentMethods();

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          final paymentMethod = paymentMethods[index];
          return _buildPaymentMethodItem(paymentMethod);
        },
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod paymentMethod) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          // Payment Method Icon
          Container(
            width: 48,
            height: 48,
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
          const SizedBox(width: 16),

          // Payment Method Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      paymentMethod.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (paymentMethod.isNew &&
                        paymentMethod.newTag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          paymentMethod.newTag!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  paymentMethod.description,
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

  List<PaymentMethod> _getMockPaymentMethods() {
    return [
      const PaymentMethod(
        id: 'banxa',
        name: 'Banxa',
        description: 'Card, Google Pay or bank transfer',
        iconPath: '',
      ),
      const PaymentMethod(
        id: 'moonpay',
        name: 'MoonPay',
        description: 'Card, Google Pay or bank transfer',
        iconPath: '',
        isNew: true,
        newTag: 'New? No fees!',
      ),
      const PaymentMethod(
        id: 'simplex',
        name: 'Simplex',
        description: 'Card, Google Pay or Direct SEPA',
        iconPath: '',
      ),
      const PaymentMethod(
        id: 'coinbase',
        name: 'CoinBase',
        description: 'Card, Google Pay or bank transfer',
        iconPath: '',
      ),
    ];
  }
}
