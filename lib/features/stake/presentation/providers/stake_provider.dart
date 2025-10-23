import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stake_provider.g.dart';

enum StakeStep {
  overview,
  validatorSelection,
  amountInput,
  confirmation,
  details,
}

class Validator {
  final String name;
  final double apy;
  final double commission;
  final double totalStake;
  final String iconUrl;

  const Validator({
    required this.name,
    required this.apy,
    required this.commission,
    required this.totalStake,
    required this.iconUrl,
  });
}

class StakePosition {
  final String validatorName;
  final double amount;
  final double apy;
  final DateTime startDate;
  final DateTime accrualDate;
  final DateTime distributionDate;
  final double earnings;

  const StakePosition({
    required this.validatorName,
    required this.amount,
    required this.apy,
    required this.startDate,
    required this.accrualDate,
    required this.distributionDate,
    required this.earnings,
  });
}

class StakeStateData {
  final StakeStep currentStep;
  final String selectedValidator;
  final String amount;
  final String currency;
  final List<StakePosition> activeStakes;
  final double totalEarnings;
  final double averageApy;
  final String? errorMessage;

  const StakeStateData({
    this.currentStep = StakeStep.overview,
    this.selectedValidator = '',
    this.amount = '',
    this.currency = 'SOL',
    this.activeStakes = const [],
    this.totalEarnings = 0.0,
    this.averageApy = 0.0,
    this.errorMessage,
  });

  StakeStateData copyWith({
    StakeStep? currentStep,
    String? selectedValidator,
    String? amount,
    String? currency,
    List<StakePosition>? activeStakes,
    double? totalEarnings,
    double? averageApy,
    String? errorMessage,
  }) {
    return StakeStateData(
      currentStep: currentStep ?? this.currentStep,
      selectedValidator: selectedValidator ?? this.selectedValidator,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      activeStakes: activeStakes ?? this.activeStakes,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      averageApy: averageApy ?? this.averageApy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class StakeNotifier extends _$StakeNotifier {
  @override
  StakeStateData build() {
    return StakeStateData(
      activeStakes: [
        StakePosition(
          validatorName: 'Nimbus Validator',
          amount: 0.832,
          apy: 6.91,
          startDate: DateTime(2024, 8, 23),
          accrualDate: DateTime(2024, 8, 24),
          distributionDate: DateTime(2024, 9, 2),
          earnings: 124.89,
        ),
        StakePosition(
          validatorName: 'Nimbus Validator',
          amount: 0.593,
          apy: 6.91,
          startDate: DateTime(2024, 8, 20),
          accrualDate: DateTime(2024, 8, 21),
          distributionDate: DateTime(2024, 8, 30),
          earnings: 90.21,
        ),
        StakePosition(
          validatorName: 'SunSol Validator',
          amount: 11.38,
          apy: 6.82,
          startDate: DateTime(2024, 7, 15),
          accrualDate: DateTime(2024, 7, 16),
          distributionDate: DateTime(2024, 8, 15),
          earnings: 1159.53,
        ),
        StakePosition(
          validatorName: 'Ubik Capital',
          amount: 0.832,
          apy: 7.57,
          startDate: DateTime(2024, 8, 10),
          accrualDate: DateTime(2024, 8, 11),
          distributionDate: DateTime(2024, 9, 10),
          earnings: 124.89,
        ),
      ],
      totalEarnings: 3892.28,
      averageApy: 3.6,
    );
  }

  void selectValidator(String validator) {
    state = state.copyWith(
      selectedValidator: validator,
      errorMessage: null,
    );
  }

  void updateAmount(String amount) {
    state = state.copyWith(
      amount: amount,
      errorMessage: null,
    );
  }

  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  void nextStep() {
    switch (state.currentStep) {
      case StakeStep.overview:
        state = state.copyWith(currentStep: StakeStep.validatorSelection);
        break;
      case StakeStep.validatorSelection:
        if (canProceedToAmount) {
          state = state.copyWith(currentStep: StakeStep.amountInput);
        }
        break;
      case StakeStep.amountInput:
        if (canProceedToConfirmation) {
          // Skip confirmation step - modal handles confirmation
          _executeStaking();
        }
        break;
      case StakeStep.confirmation:
        // Execute staking and go to details
        _executeStaking();
        break;
      case StakeStep.details:
        // Already at final step
        break;
    }
  }

  void previousStep() {
    switch (state.currentStep) {
      case StakeStep.overview:
        // Already at first step
        break;
      case StakeStep.validatorSelection:
        state = state.copyWith(currentStep: StakeStep.overview);
        break;
      case StakeStep.amountInput:
        state = state.copyWith(currentStep: StakeStep.validatorSelection);
        break;
      case StakeStep.confirmation:
        state = state.copyWith(currentStep: StakeStep.amountInput);
        break;
      case StakeStep.details:
        state = state.copyWith(currentStep: StakeStep.overview);
        break;
    }
  }

  void goToDetails() {
    state = state.copyWith(currentStep: StakeStep.details);
  }

  void goToOverview() {
    state = state.copyWith(currentStep: StakeStep.overview);
  }

  void _executeStaking() {
    // Simulate staking execution
    final newStake = StakePosition(
      validatorName: state.selectedValidator,
      amount: double.parse(state.amount),
      apy: _getValidatorApy(state.selectedValidator),
      startDate: DateTime.now(),
      accrualDate: DateTime.now().add(const Duration(days: 1)),
      distributionDate: DateTime.now().add(const Duration(days: 10)),
      earnings: 0.0,
    );

    final updatedStakes = [...state.activeStakes, newStake];
    final newTotalEarnings = state.totalEarnings +
        (double.parse(state.amount) *
            _getValidatorApy(state.selectedValidator) /
            100);

    state = state.copyWith(
      currentStep: StakeStep.details,
      activeStakes: updatedStakes,
      totalEarnings: newTotalEarnings,
    );
  }

  double _getValidatorApy(String validator) {
    switch (validator) {
      case 'Nimbus Validator':
        return 6.91;
      case 'SunSol Validator':
        return 6.82;
      case 'Ubik Capital':
        return 7.57;
      case 'Solana Compass':
        return 6.76;
      case 'Allnodes':
        return 7.1;
      case 'Restake':
        return 6.8;
      case 'Egor':
        return 7.5;
      default:
        return 6.5;
    }
  }

  void setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  bool get canProceedToAmount {
    return state.selectedValidator.isNotEmpty;
  }

  bool get canProceedToConfirmation {
    return state.amount.isNotEmpty &&
        double.tryParse(state.amount) != null &&
        double.parse(state.amount) > 0;
  }

  bool get canExecuteStaking {
    return canProceedToConfirmation;
  }

  List<Validator> get validators {
    return const [
      Validator(
        name: 'Nimbus Validator',
        apy: 6.91,
        commission: 4.0,
        totalStake: 1516296.0,
        iconUrl: 'https://example.com/nimbus.png',
      ),
      Validator(
        name: 'Solana Compass',
        apy: 6.76,
        commission: 5.0,
        totalStake: 1516296.0,
        iconUrl: 'https://example.com/compass.png',
      ),
      Validator(
        name: 'Ubik Capital',
        apy: 7.57,
        commission: 3.0,
        totalStake: 319594.0,
        iconUrl: 'https://example.com/ubik.png',
      ),
      Validator(
        name: 'SunSol Validator',
        apy: 6.82,
        commission: 4.5,
        totalStake: 53295.0,
        iconUrl: 'https://example.com/sunsol.png',
      ),
      Validator(
        name: 'Allnodes',
        apy: 7.1,
        commission: 2.0,
        totalStake: 1061211.0,
        iconUrl: 'https://example.com/allnodes.png',
      ),
      Validator(
        name: 'Restake',
        apy: 6.8,
        commission: 5.5,
        totalStake: 23269.0,
        iconUrl: 'https://example.com/restake.png',
      ),
      Validator(
        name: 'Egor',
        apy: 7.5,
        commission: 2.5,
        totalStake: 32004.0,
        iconUrl: 'https://example.com/egor.png',
      ),
    ];
  }
}
