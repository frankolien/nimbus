import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/stake_provider.dart';

class StakeOverviewScreen extends ConsumerStatefulWidget {
  const StakeOverviewScreen({super.key});

  @override
  ConsumerState<StakeOverviewScreen> createState() =>
      _StakeOverviewScreenState();
}

class _StakeOverviewScreenState extends ConsumerState<StakeOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final stakeState = ref.watch(stakeNotifierProvider);
    final stakeNotifier = ref.read(stakeNotifierProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          // Fixed Content at Top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Earnings Summary
                _buildEarningsSummary(stakeState),

                const SizedBox(height: 24),

                // Chart Section
                _buildChartSection(),

                const SizedBox(height: 24),

                // Active Stakes Header
                _buildActiveStakesHeader(),
              ],
            ),
          ),

          // Scrollable Active Stakes List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: stakeState.activeStakes.length,
                itemBuilder: (context, index) {
                  final stake = stakeState.activeStakes[index];
                  return _buildStakeItem(stake, stakeNotifier);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary(StakeStateData state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total earned',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${state.totalEarnings.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            const Text(
              'Average rate',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              '${state.averageApy.toStringAsFixed(1)}% APY',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price header

        // Chart
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const labels = ['1H', '1D', '1W', '1M', '1Y', 'ALL'];
                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[value.toInt()],
                            style: TextStyle(
                              color: value.toInt() == 4
                                  ? Colors.orange
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    interval: 1,
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 5,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 2),
                    FlSpot(1, 1.8),
                    FlSpot(2, 2.2),
                    FlSpot(3, 3),
                    FlSpot(4, 4.5),
                    FlSpot(5, 5.5),
                  ],
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.5),
                        Colors.green.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStakesHeader() {
    return const Text(
      'Active stakes',
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStakeItem(StakePosition stake, StakeNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          // Validator icon
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/test_validator.png', // Test asset
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(
                    'Error loading validator asset: assets/images/test_validator.png, Error: $error');
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A17B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 20,
                  ),
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
                  stake.validatorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stake.apy.toStringAsFixed(2)}% APY',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Earnings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ \$${stake.earnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF26A17B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+ ${stake.amount.toStringAsFixed(3)} SOL',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Details button
          GestureDetector(
            onTap: () {
              notifier.goToDetails();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
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
}
