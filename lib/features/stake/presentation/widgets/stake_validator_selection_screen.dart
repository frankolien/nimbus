import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stake_provider.dart';

class StakeValidatorSelectionScreen extends ConsumerStatefulWidget {
  const StakeValidatorSelectionScreen({super.key});

  @override
  ConsumerState<StakeValidatorSelectionScreen> createState() =>
      _StakeValidatorSelectionScreenState();
}

class _StakeValidatorSelectionScreenState
    extends ConsumerState<StakeValidatorSelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  AnimationController? _animationController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController?.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stakeNotifier = ref.read(stakeNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            //_buildHeader(context),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Search Bar
                    _buildSearchBar(),

                    const SizedBox(height: 24),

                    // Column Headers
                    _buildColumnHeaders(),

                    const SizedBox(height: 16),

                    // Validator List
                    Expanded(
                      child: _buildValidatorList(stakeNotifier),
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white54, size: 24),
              hintText: 'search validators',
              hintStyle: TextStyle(
                color: Colors.white38,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchController.clear();
            },
            child: const Icon(
              Icons.close,
              color: Colors.white54,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildColumnHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Row(
            children: [
              const Text(
                'Validator',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Text(
                'est. APY',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidatorList(StakeNotifier notifier) {
    final validators = notifier.validators
        .where((v) => v.name.toLowerCase().contains(_searchQuery))
        .toList();

    if (validators.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              'No validators found',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: validators.length,
      itemBuilder: (context, index) {
        final validator = validators[index];
        return _buildValidatorItem(validator, notifier, index);
      },
    );
  }

  Widget _buildValidatorItem(
      Validator validator, StakeNotifier notifier, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              notifier.selectValidator(validator.name);
              notifier.nextStep();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Validator icon with gradient
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      _getValidatorAsset(validator.name),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            'Error loading validator asset: ${_getValidatorAsset(validator.name)}, Error: $error');
                        return Icon(
                          _getValidatorIcon(validator.name),
                          color: Colors.white,
                          size: 28,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Validator info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          validator.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatStake(validator.totalStake),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // APY
                  Text(
                    '${validator.apy.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatStake(double stake) {
    if (stake >= 1000000) {
      return '${(stake / 1000000).toStringAsFixed(2)}M SOL';
    } else if (stake >= 1000) {
      return '${(stake / 1000).toStringAsFixed(0)},${(stake % 1000).toStringAsFixed(0).padLeft(3, '0')} SOL';
    }
    return '${stake.toStringAsFixed(0)} SOL';
  }

  LinearGradient _getValidatorGradient(String name) {
    final color = _getValidatorColor(name);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
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
