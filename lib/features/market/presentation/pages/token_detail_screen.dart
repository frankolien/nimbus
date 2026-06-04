import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../onboarding/presentation/widgets/nimbus_widgets.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../transfer/presentation/pages/receive_screen.dart';
import '../../../transfer/presentation/pages/send_screen.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../data/market_service.dart';
import '../providers/market_providers.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/market_stats_list.dart';
import '../widgets/timeframe_selector.dart';
import '../widgets/token_app_bar.dart';
import '../widgets/token_identity.dart';

/// Token detail: live price, candlestick chart with timeframe tabs, and market
/// stats — all real market data. Composes presentational widgets; holds only
/// the selected timeframe.
class TokenDetailScreen extends ConsumerStatefulWidget {
  const TokenDetailScreen({super.key, required this.network});
  final Network network;

  @override
  ConsumerState<TokenDetailScreen> createState() => _TokenDetailScreenState();
}

class _TokenDetailScreenState extends ConsumerState<TokenDetailScreen> {
  Timeframe _timeframe = Timeframe.d1;

  Network get _network => widget.network;

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(portfolioProvider).valueOrNull?.entries
        .where((e) => e.network == _network)
        .firstOrNull;
    final candles = ref.watch(candlesProvider((_network, _timeframe)));
    final stats = ref.watch(marketStatsProvider(_network));

    return Scaffold(
      backgroundColor: NB.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            TokenAppBar(
              onBack: () => Navigator.of(context).maybePop(),
              onCopy: () {},
              onFavorite: () {},
            ),
            const SizedBox(height: 18),
            TokenIdentity(network: _network),
            const SizedBox(height: 16),
            TokenPriceHeader(price: entry?.usdPrice, change24h: entry?.change24h),
            const SizedBox(height: 18),
            _Chart(candles: candles),
            const SizedBox(height: 14),
            TimeframeSelector(
              selected: _timeframe,
              onSelect: (tf) => setState(() => _timeframe = tf),
            ),
            const SizedBox(height: 26),
            MarketStatsList(stats: stats.valueOrNull, loading: stats.isLoading),
            const SizedBox(height: 20),
            _Actions(),
          ],
        ),
      ),
    );
  }
}

/// Renders the chart's loading / empty / error / data states.
class _Chart extends StatelessWidget {
  const _Chart({required this.candles});
  final AsyncValue<List<Candle>> candles;

  @override
  Widget build(BuildContext context) {
    return candles.when(
      data: (data) => data.isEmpty
          ? _message('Chart unavailable for this asset')
          : CandlestickChart(candles: data),
      loading: () => const Skeleton(width: double.infinity, height: 280, radius: 16),
      error: (_, __) => _message('Couldn’t load chart'),
    );
  }

  Widget _message(String msg) => SizedBox(
        height: 280,
        child: Center(child: Text(msg, style: NB.font(13.5, color: NB.text3))),
      );
}

class _Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void push(Widget p) =>
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => p));
    return Row(
      children: [
        Expanded(
          child: NbButton(
            label: 'Receive',
            variant: NbBtnVariant.ghost,
            onTap: () => push(const ReceiveScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NbButton(label: 'Send', onTap: () => push(const SendScreen())),
        ),
      ],
    );
  }
}
