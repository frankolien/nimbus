import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stake_provider.dart';

class StakeConfirmationScreen extends ConsumerStatefulWidget {
  const StakeConfirmationScreen({super.key});

  @override
  ConsumerState<StakeConfirmationScreen> createState() =>
      _StakeConfirmationScreenState();
}

class _StakeConfirmationScreenState
    extends ConsumerState<StakeConfirmationScreen>
    with TickerProviderStateMixin {
  AnimationController? _slideController;
  Animation<double>? _slideAnimation;
  double _slidePosition = 0.0;
  bool _isConfirming = false;
  double _slideWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stakeState = ref.watch(stakeNotifierProvider);
    final stakeNotifier = ref.read(stakeNotifierProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Review Stake Header
            _buildReviewHeader(),

            const SizedBox(height: 24),

            // Stake Summary
            _buildStakeSummary(stakeState, stakeNotifier),

            const Spacer(),

            // Slide to Confirm
            Padding(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _slideWidth = constraints.maxWidth;
                  return _buildSlideToConfirm(stakeNotifier);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            final stakeNotifier = ref.read(stakeNotifierProvider.notifier);
            stakeNotifier.previousStep();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Review stake',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStakeSummary(StakeStateData state, StakeNotifier notifier) {
    final validator = notifier.validators.firstWhere(
      (v) => v.name == state.selectedValidator,
      orElse: () => notifier.validators.first,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          const Text(
            'You are staking',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.amount} SOL',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Validator', validator.name),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Estimated APY', '${validator.apy.toStringAsFixed(2)}%'),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Commission', '${validator.commission.toStringAsFixed(1)}%'),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Total stake', '${validator.totalStake.toStringAsFixed(0)} SOL'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSlideToConfirm(StakeNotifier notifier) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!_isConfirming) {
          setState(() {
            _slidePosition += details.delta.dx;
            _slidePosition = _slidePosition.clamp(
                0.0, _slideWidth - 60); // 60 is button width
            _slideController?.value = _slidePosition / (_slideWidth - 60);
          });
        }
      },
      onPanEnd: (details) {
        if (!_isConfirming) {
          if ((_slideController?.value ?? 0) >= 0.8) {
            // 80% threshold
            _confirmStaking(notifier);
          } else {
            _slideController?.reverse();
            setState(() {
              _slidePosition = 0;
            });
          }
        }
      },
      child: _slideAnimation != null
          ? AnimatedBuilder(
              animation: _slideAnimation!,
              builder: (context, child) {
                return Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _isConfirming ? 'Processing...' : 'Slide to confirm',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Positioned(
                        left: _slideAnimation!.value * (_slideWidth - 60),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: _isConfirming
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFF6B35)),
                                  strokeWidth: 3,
                                )
                              : const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFFF6B35),
                                  size: 28,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Slide to confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
    );
  }

  void _confirmStaking(StakeNotifier notifier) async {
    setState(() {
      _isConfirming = true;
    });

    // Simulate staking processing
    await Future.delayed(const Duration(seconds: 2));

    notifier.nextStep(); // This will execute staking and go to details

    if (mounted) {
      _showSuccessScreen();
    }
  }

  void _showSuccessScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF26A17B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SOL Staked',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You successfully staked ${ref.read(stakeNotifierProvider).amount} SOL on ${ref.read(stakeNotifierProvider).selectedValidator}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to overview
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF333333)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View on explorer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to overview
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Okay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
