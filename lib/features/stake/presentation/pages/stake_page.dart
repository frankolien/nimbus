import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stake_provider.dart';
import '../widgets/stake_overview_screen.dart';
import '../widgets/stake_validator_selection_screen.dart';
import '../widgets/stake_amount_input_screen.dart';
import '../widgets/stake_confirmation_screen.dart';
import '../widgets/stake_details_screen.dart';

class StakePage extends ConsumerStatefulWidget {
  const StakePage({super.key});

  @override
  ConsumerState<StakePage> createState() => _StakePageState();
}

class _StakePageState extends ConsumerState<StakePage> {
  @override
  Widget build(BuildContext context) {
    final stakeState = ref.watch(stakeNotifierProvider);
    final stakeNotifier = ref.read(stakeNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (stakeState.currentStep == StakeStep.overview) {
              Navigator.of(context).pop();
            } else {
              stakeNotifier.previousStep();
            }
          },
        ),
        title: Text(
          _getAppBarTitle(stakeState.currentStep),
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
      body: _getCurrentScreen(stakeState.currentStep),
      floatingActionButton: stakeState.currentStep == StakeStep.overview
          ? FloatingActionButton(
              onPressed: () => stakeNotifier.nextStep(),
              backgroundColor: const Color(0xFF333333),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _getCurrentScreen(StakeStep step) {
    switch (step) {
      case StakeStep.overview:
        return const StakeOverviewScreen();
      case StakeStep.validatorSelection:
        return const StakeValidatorSelectionScreen();
      case StakeStep.amountInput:
        return const StakeAmountInputScreen();
      case StakeStep.confirmation:
        return const StakeConfirmationScreen();
      case StakeStep.details:
        return const StakeDetailsScreen();
    }
  }

  String _getAppBarTitle(StakeStep step) {
    switch (step) {
      case StakeStep.overview:
        return 'Stake';
      case StakeStep.validatorSelection:
        return 'Select validator';
      case StakeStep.amountInput:
        return 'Stake';
      case StakeStep.confirmation:
        return 'Stake';
      case StakeStep.details:
        return 'Stake';
    }
  }

  void _refreshData() {
    ref.invalidate(stakeNotifierProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        backgroundColor: Color(0xFFFF6B35),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
