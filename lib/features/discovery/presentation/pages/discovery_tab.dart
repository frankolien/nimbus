import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../market/presentation/pages/token_detail_screen.dart';
import '../../../wallet/domain/entities/network.dart';
import '../../../wallet/presentation/providers/wallet_session.dart';
import '../../data/dapp_catalog.dart';
import '../../domain/trending_token.dart';
import '../providers/discovery_providers.dart';
import '../widgets/browse_grid.dart';
import '../widgets/chain_filter_chips.dart';
import '../widgets/dapp_row.dart';
import '../widgets/section_head.dart';
import '../widgets/spotlight_card.dart';
import '../widgets/trending_list.dart';

/// The Explore/Discovery tab: search, chain filters, a Spotlight dApp carousel,
/// Browse shortcuts, a realtime Trending token list (CoinGecko, polled), and
/// Popular apps. Curated dApps open their real sites; tokens drill into the
/// in-app detail screen when they map to a supported chain.
class DiscoveryTab extends ConsumerStatefulWidget {
  const DiscoveryTab({super.key});

  @override
  ConsumerState<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends ConsumerState<DiscoveryTab> {
  final _search = TextEditingController();
  String _query = '';
  String _chain = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _searching => _query.isNotEmpty;

  bool _matches(String text) =>
      _query.isEmpty || text.toLowerCase().contains(_query.toLowerCase());

  bool _onChain(String chainId) => _chain == 'all' || chainId == _chain;

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: NB.surface2,
          behavior: SnackBarBehavior.floating,
          content: Text('Coming soon', style: NB.font(13, color: NB.text)),
          duration: const Duration(seconds: 1),
        ),
      );

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  void _openToken(TrendingToken token) {
    final match =
        Network.values.where((n) => n.nativeSymbol == token.symbol).firstOrNull;
    if (match != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TokenDetailScreen(network: match)),
      );
    } else {
      _soon();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trending = ref.watch(trendingProvider(_chain));
    final label = ref.watch(
        walletSessionProvider.select((s) => s.activeAccount?.label ?? 'Nimbus'));

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(label),
          Expanded(
            child: RefreshIndicator(
              color: NB.orange,
              backgroundColor: NB.surface,
              onRefresh: () =>
                  ref.read(trendingProvider(_chain).notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SearchField(
                      controller: _search,
                      hint: 'Search apps, tokens, collections',
                      dense: true,
                      onChanged: (v) => setState(() => _query = v),
                      onClear: () => setState(() {
                        _search.clear();
                        _query = '';
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ChainFilterChips(
                    selected: _chain,
                    onSelect: (c) => setState(() => _chain = c),
                  ),
                  const SizedBox(height: 16),
                  if (!_searching) ..._spotlight(),
                  if (!_searching) ..._browse(),
                  ..._trending(trending),
                  ..._popular(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String label) {
    final initial = label.trim().isEmpty ? 'N' : label.trim()[0].toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Explore',
              style: NB.font(24, weight: FontWeight.w800, letterSpacing: -0.6)),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [NB.orangeHi, Color(0xFFB83A0C)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(initial, style: NB.font(14, weight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  List<Widget> _spotlight() {
    final spots = spotlightDapps.where((d) => _onChain(d.chainId)).toList();
    if (spots.isEmpty) return const [];
    return [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SectionHead(title: 'Spotlight'),
      ),
      SizedBox(
        height: 142,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: spots.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) =>
              SpotlightCard(dapp: spots[i], onOpen: () => _open(spots[i].url)),
        ),
      ),
      const SizedBox(height: 18),
    ];
  }

  List<Widget> _browse() {
    return [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SectionHead(title: 'Browse'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BrowseGrid(onTap: (_) => _soon()),
      ),
      const SizedBox(height: 18),
    ];
  }

  List<Widget> _trending(AsyncValue<List<TrendingToken>> trending) {
    final content = trending.when(
      loading: () => const TrendingListSkeleton(),
      error: (_, __) => _message('Couldn’t load trending tokens'),
      data: (tokens) {
        final filtered =
            tokens.where((t) => _matches(t.symbol) || _matches(t.name)).toList();
        if (filtered.isEmpty) {
          return _message(_searching
              ? 'No tokens match “$_query”'
              : 'No trending tokens here yet');
        }
        return TrendingList(tokens: filtered, onTap: _openToken);
      },
    );

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SectionHead(title: 'Trending', actionLabel: 'See all', onAction: _soon),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: content,
      ),
      const SizedBox(height: 18),
    ];
  }

  List<Widget> _popular() {
    final apps = popularDapps
        .where((d) => _onChain(d.chainId) && _matches(d.name))
        .toList();
    if (apps.isEmpty) return const [];
    return [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SectionHead(title: 'Popular apps'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (final a in apps) ...[
              DappRow(dapp: a, onOpen: () => _open(a.url)),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _message(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(child: Text(text, style: NB.font(14, color: NB.text3))),
      );
}
