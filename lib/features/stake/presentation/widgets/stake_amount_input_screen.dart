import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stake_provider.dart';
import 'stake_confirmation_modal.dart';

class StakeAmountInputScreen extends ConsumerStatefulWidget {
  const StakeAmountInputScreen({super.key});

  @override
  ConsumerState<StakeAmountInputScreen> createState() =>
      _StakeAmountInputScreenState();
}

class _StakeAmountInputScreenState extends ConsumerState<StakeAmountInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  AnimationController? _animationController;
  bool _showValidatorDetails = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController?.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stakeState = ref.watch(stakeNotifierProvider);
    final stakeNotifier = ref.read(stakeNotifierProvider.notifier);

    return Scaffold(
      //backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            //_buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // From Section
                    _buildFromSection(stakeState, stakeNotifier),

                    const SizedBox(height: 40),

                    // Amount Input
                    _buildAmountInput(stakeState, stakeNotifier),

                    const SizedBox(height: 40),

                    // Validator Section
                    _buildValidatorSection(stakeState, stakeNotifier),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Continue Button
            _buildContinueButton(stakeState, stakeNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Select validator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFromSection(StakeStateData state, StakeNotifier notifier) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'From',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // SOL Token Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2D30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://assets.coingecko.com/coins/images/4128/large/solana.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9945FF), Color(0xFF14F195)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SOL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Balance
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '329.27',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(StakeStateData state, StakeNotifier notifier) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Amount Input Field
          Expanded(
            child: TextField(
              controller: _amountController,
              focusNode: _focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -2,
                height: 1,
              ),
              textAlign: TextAlign.start,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                hintText: 'Amount',
                fillColor: Colors.transparent,
                filled: true,
                hintStyle: TextStyle(
                  color: Colors.white24,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                notifier.updateAmount(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Max Button
          GestureDetector(
            onTap: () {
              _amountController.text = '329.27';
              notifier.updateAmount('329.27');
              HapticFeedback.selectionClick();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6B35),
                  width: 1.5,
                ),
              ),
              child: const Text(
                'Max',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidatorSection(StakeStateData state, StakeNotifier notifier) {
    final validator = notifier.validators.firstWhere(
      (v) => v.name == state.selectedValidator,
      orElse: () => notifier.validators.first,
    );

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Validator',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Validator Selector
          GestureDetector(
            onTap: () {
              setState(() {
                _showValidatorDetails = !_showValidatorDetails;
              });
              HapticFeedback.selectionClick();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2D30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _getValidatorAsset(validator.name),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            'Error loading validator asset: ${_getValidatorAsset(validator.name)}, Error: $error');
                        return Icon(
                          _getValidatorIcon(validator.name),
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      validator.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _showValidatorDetails
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white54,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Validator Details (Expandable)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showValidatorDetails
                ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2D30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Estimated APY',
                          '${validator.apy.toStringAsFixed(2)}%',
                          Icons.trending_up,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Commission',
                          '${validator.commission.toStringAsFixed(1)} %',
                          Icons.percent,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Total stake',
                          '${_formatNumber(validator.totalStake)} SOL',
                          Icons.account_balance_wallet,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white54,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(StakeStateData state, StakeNotifier notifier) {
    final canProceed = notifier.canProceedToConfirmation;

    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: canProceed
            ? () {
                HapticFeedback.mediumImpact();
                _showConfirmationModal(context, notifier);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: canProceed
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF97316)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: canProceed ? null : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: canProceed
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            'Continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: canProceed ? Colors.white : Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(0);
  }

  /*LinearGradient _getValidatorGradient(String name) {
    final color = _getValidatorColor(name);
    return LinearGradient(
      colors: [color, color.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }*/

  /*Color _getValidatorColor(String name) {
    switch (name) {
      case 'Nimbus Validator':
        return const Color(0xFFFF6B35);
      case 'Solana Compass':
        return const Color(0xFF26A17B);
      case 'Ubik Capital':
        return const Color(0xFF627EEA);
      case 'SunSol Validator':
        return const Color(0xFFF7931A);
      case 'Allnodes':
        return const Color(0xFF9945FF);
      case 'Restake':
        return const Color(0xFF0088CC);
      case 'Egor':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF666666);
    }
  }*/

  String _getValidatorAsset(String name) {
    final assetPath = switch (name) {
      'Nimbus Validator' => 'assets/images/nimbus_validator.png',
      'Solana Compass' => 'assets/images/solana_compass_validator.png',
      'Ubik Capital' => 'assets/images/Ubik_capital_validator.png',
      'SunSol Validator' => 'assets/images/SunSol_validator.png',
      'Allnodes' => 'assets/images/All_nodes_validator.png',
      'Restake' => 'assets/images/Restake_validator.png',
      'Egor' => 'assets/images/Egor_validator.png',
      _ => 'assets/images/nimbus_validator.png',
    };
    print('Loading validator asset for $name: $assetPath');
    return assetPath;
  }

  IconData _getValidatorIcon(String name) {
    switch (name) {
      case 'Nimbus Validator':
        return Icons.account_balance;
      case 'Solana Compass':
        return Icons.explore;
      case 'Ubik Capital':
        return Icons.business;
      case 'SunSol Validator':
        return Icons.wb_sunny;
      case 'Allnodes':
        return Icons.cloud;
      case 'Restake':
        return Icons.refresh;
      case 'Egor':
        return Icons.person;
      default:
        return Icons.account_balance;
    }
  }

  void _showConfirmationModal(BuildContext context, StakeNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StakeConfirmationModal(),
    );
  }
}
