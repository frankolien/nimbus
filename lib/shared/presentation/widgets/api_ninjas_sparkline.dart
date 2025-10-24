import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CoinGeckoSparkline extends StatefulWidget {
  final String symbol; // e.g. "bitcoin", "ethereum"
  final Duration pollInterval; // e.g. Duration(minutes: 1)

  const CoinGeckoSparkline({
    super.key,
    this.symbol = 'bitcoin',
    this.pollInterval = const Duration(minutes: 1),
  });

  @override
  State<CoinGeckoSparkline> createState() => _CoinGeckoSparklineState();
}

class _CoinGeckoSparklineState extends State<CoinGeckoSparkline> {
  final List<double> _prices = []; // simple price series
  final List<int> _timestamps = []; // epoch seconds matching prices
  Timer? _timer;
  bool _loading = true;
  double _latest = 0;
  String _selectedTimeframe = '1D';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // fetch right away then schedule
    _fetchOnce();
    _timer = Timer.periodic(widget.pollInterval, (_) => _fetchOnce());
  }

  Future<void> _fetchOnce() async {
    // Check if widget is still mounted before making any setState calls
    if (!mounted) return;

    // Map timeframe to CoinGecko days parameter
    final days = _getDaysForTimeframe(_selectedTimeframe);
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/${widget.symbol}/market_chart?vs_currency=usd&days=$days');

    try {
      final res = await http.get(url);
      if (res.statusCode != 200) {
        debugPrint('CoinGecko error ${res.statusCode}: ${res.body}');
        if (mounted) {
          setState(() {
            _loading = false;
            _errorMessage = 'Failed to fetch data (${res.statusCode})';
          });
        }
        return;
      }

      final Map body = json.decode(res.body) as Map;
      final List<dynamic> prices = body['prices'] as List;

      if (prices.isEmpty) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }

      // Clear existing data and populate with new data
      if (mounted) {
        setState(() {
          _prices.clear();
          _timestamps.clear();

          for (final priceData in prices) {
            final timestamp =
                (priceData[0] as num).toInt() ~/ 1000; // Convert to seconds
            final price = (priceData[1] as num).toDouble();
            _timestamps.add(timestamp);
            _prices.add(price);
          }

          _latest = _prices.isNotEmpty ? _prices.last : 0.0;
          _loading = false;
          _errorMessage = null;
        });
      }
    } catch (e, st) {
      debugPrint('Failed fetch price: $e\n$st');
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Network error: ${e.toString()}';
        });
      }
    }
  }

  int _getDaysForTimeframe(String timeframe) {
    switch (timeframe) {
      case '1H':
        return 1; // CoinGecko minimum is 1 day
      case '1D':
        return 1;
      case '1W':
        return 7;
      case '1M':
        return 30;
      case 'YTD':
        return 365;
      case 'ALL':
        return 365; // Max for free tier
      default:
        return 1;
    }
  }

  List<FlSpot> _toSpots() {
    if (_prices.isEmpty) return [];
    // use index as x to keep it simple (0..n-1)
    return List.generate(
        _prices.length, (i) => FlSpot(i.toDouble(), _prices[i]));
  }

  LineChartData _chartData() {
    final spots = _toSpots();
    if (spots.isEmpty) {
      return LineChartData(
        lineBarsData: [],
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
      );
    }

    final minY = _prices.reduce((a, b) => a < b ? a : b);
    final maxY = _prices.reduce((a, b) => a > b ? a : b);
    final isPositive = _prices.last >= _prices.first;
    final chartColor =
        isPositive ? const Color(0xFF00D4AA) : const Color(0xFFFF6B6B);

    return LineChartData(
      minY: minY * 0.995,
      maxY: maxY * 1.005,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 8,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              return LineTooltipItem(
                '\$${touchedSpot.y.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: chartColor,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: chartColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                chartColor.withOpacity(0.3),
                chartColor.withOpacity(0.1),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          color: chartColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceStr = NumberFormat.currency(symbol: '\$').format(_latest);
    final change = (_prices.length >= 2) ? (_prices.last - _prices.first) : 0.0;
    final changePct = (_prices.length >= 2 && _prices.first != 0)
        ? (change / _prices.first) * 100
        : 0.0;
    final changeColor =
        change >= 0 ? const Color(0xFF00D4AA) : const Color(0xFFFF6B6B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.symbol.toUpperCase(),
                        style: const TextStyle(
                            color: Color(0xFF999999), fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(priceStr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                  ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${change >= 0 ? '+' : ''}\$${change.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${change >= 0 ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),

        // chart
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            //color: const Color(0xFF0A0A0A),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _loading && _prices.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
                ))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFFF6B6B),
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : LineChart(_chartData()),
        ),

        // range chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeframeChip('1H'),
              _buildTimeframeChip('1D'),
              _buildTimeframeChip('1W'),
              _buildTimeframeChip('1M'),
              _buildTimeframeChip('YTD'),
              _buildTimeframeChip('ALL'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeChip(String timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            _selectedTimeframe = timeframe;
            _loading = true;
            _errorMessage = null;
          });
          _fetchOnce(); // Fetch new data for the selected timeframe
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D4AA) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          timeframe,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFF00D4AA) : const Color(0xFF999999),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
