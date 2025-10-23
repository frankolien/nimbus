import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stake_provider.dart';

class StakeDetailsScreen extends ConsumerStatefulWidget {
  const StakeDetailsScreen({super.key});

  @override
  ConsumerState<StakeDetailsScreen> createState() => _StakeDetailsScreenState();
}

class _StakeDetailsScreenState extends ConsumerState<StakeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final stakeState = ref.watch(stakeNotifierProvider);
    final stakeNotifier = ref.read(stakeNotifierProvider.notifier);

    // Get the most recent stake (the one just created)
    final latestStake = stakeState.activeStakes.isNotEmpty
        ? stakeState.activeStakes.last
        : null;

    if (latestStake == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: Text(
            'No stake details available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Details Header
            _buildDetailsHeader(),

            const SizedBox(height: 10),

            // Stake Amount
            _buildStakeAmount(latestStake),

            const SizedBox(height: 24),

            // Validator Info
            _buildValidatorInfo(latestStake),

            const SizedBox(height: 24),

            // Stake Details
            _buildStakeDetails(latestStake),

            const Spacer(),

            // Unstake Button
            Padding(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: _buildUnstakeButton(stakeNotifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsHeader() {
    return const Text(
      'Details',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStakeAmount(StakePosition stake) {
    return Column(
      children: [
        Text(
          '${stake.amount.toStringAsFixed(0)} SOL',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${(stake.amount * 190).toStringAsFixed(0)}', // Mock USD conversion
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildValidatorInfo(StakePosition stake) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getValidatorColor(stake.validatorName),
            borderRadius: BorderRadius.circular(25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              _getValidatorAsset(stake.validatorName),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(
                    'Error loading validator asset: ${_getValidatorAsset(stake.validatorName)}, Error: $error');
                return Icon(
                  _getValidatorIcon(stake.validatorName),
                  color: Colors.white,
                  size: 25,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stake.validatorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${stake.apy.toStringAsFixed(2)}% APY',
                style: const TextStyle(
                  color: Color(0xFF26A17B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStakeDetails(StakePosition stake) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildDetailRow('Total amount in savings',
              '\$${(stake.amount * 190).toStringAsFixed(1)}'),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Total earnings', '\$${stake.earnings.toStringAsFixed(1)}'),
          const SizedBox(height: 16),
          _buildDetailRow('Start date', _formatDate(stake.startDate)),
          const SizedBox(height: 16),
          _buildDetailRow('Accrual date', _formatDate(stake.accrualDate)),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Profit distribution date', _formatDate(stake.distributionDate)),
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

  Widget _buildUnstakeButton(StakeNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showUnstakeConfirmation(notifier),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Unstake',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showUnstakeConfirmation(StakeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Unstake Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to unstake your SOL? This action cannot be undone.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _executeUnstake(notifier);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('Unstake'),
          ),
        ],
      ),
    );
  }

  void _executeUnstake(StakeNotifier notifier) {
    // Simulate unstaking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Unstaking initiated. This may take a few days to complete.'),
        backgroundColor: Color(0xFF26A17B),
        duration: Duration(seconds: 3),
      ),
    );

    // Go back to overview
    notifier.goToOverview();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getValidatorColor(String name) {
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
  }

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
}
