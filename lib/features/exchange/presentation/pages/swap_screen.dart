import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/swap_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

class SwapScreen extends ConsumerWidget {
  const SwapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swapState = ref.watch(swapStateProvider);
    final swapForm = ref.watch(swapFormProvider);
    final walletAddress = ref.watch(currentWalletAddressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Exchange'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Swap Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Sell Token
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Sell Token',
                            hintText: 'Token Address',
                          ),
                          onChanged: (value) {
                            ref
                                .read(swapFormProvider.notifier)
                                .updateSellToken(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: '0.0',
                          ),
                          onChanged: (value) {
                            ref
                                .read(swapFormProvider.notifier)
                                .updateSellAmount(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Swap Button
                  IconButton(
                    onPressed: () {
                      ref.read(swapFormProvider.notifier).swapTokens();
                    },
                    icon: const Icon(
                      Icons.swap_vert,
                      color: Color(0xFFFF6B35),
                      size: 32,
                    ),
                  ),

                  // Buy Token
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Buy Token',
                            hintText: 'Token Address',
                          ),
                          onChanged: (value) {
                            ref
                                .read(swapFormProvider.notifier)
                                .updateBuyToken(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: '0.0',
                            enabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Slippage
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Slippage (%)',
                      hintText: '0.5',
                    ),
                    initialValue: swapForm.slippagePercentage,
                    onChanged: (value) {
                      ref.read(swapFormProvider.notifier).updateSlippage(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Get Quote Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: swapForm.sellToken.isNotEmpty &&
                        swapForm.buyToken.isNotEmpty &&
                        swapForm.sellAmount.isNotEmpty
                    ? () {
                        ref.read(swapStateProvider.notifier).getSwapQuote(
                              sellToken: swapForm.sellToken,
                              buyToken: swapForm.buyToken,
                              sellAmount: swapForm.sellAmount,
                              slippagePercentage: swapForm.slippagePercentage,
                              takerAddress: walletAddress ??
                                  '0x0000000000000000000000000000000000000000',
                            );
                      }
                    : null,
                child: const Text('Get Quote'),
              ),
            ),
            const SizedBox(height: 24),

            // Quote Display
            swapState.when(
              data: (quote) {
                if (quote == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Swap Quote',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price:',
                              style: TextStyle(color: Color(0xFF999999))),
                          Text(quote.price,
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Gas:',
                              style: TextStyle(color: Color(0xFF999999))),
                          Text(quote.gas,
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Gas:',
                              style: TextStyle(color: Color(0xFF999999))),
                          Text(quote.estimatedGas,
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: walletAddress != null
                              ? () async {
                                  try {
                                    final txHash = await ref
                                        .read(swapStateProvider.notifier)
                                        .executeSwap(
                                          quote: quote,
                                          walletAddress: walletAddress,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Swap executed: $txHash'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Swap failed: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          child: const Text('Execute Swap'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              ),
              error: (error, stackTrace) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
