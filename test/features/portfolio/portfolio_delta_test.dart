import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:nimbus/features/wallet/domain/entities/network.dart';

/// A priced holding worth [value] USD that moved [change]% over 24h.
PortfolioEntry _holding(Network network, double value, double? change) =>
    PortfolioEntry(
      network: network,
      address: 'addr',
      amount: 1,
      usdPrice: value, // amount 1 → usdValue == value
      change24h: change,
    );

void main() {
  group('Portfolio.delta24h', () {
    test('is null when no asset has both a value and a 24h figure', () {
      expect(const Portfolio(entries: []).delta24h, isNull);
      expect(
        Portfolio(entries: [_holding(Network.solana, 100, null)]).delta24h,
        isNull,
      );
    });

    test('reflects a single asset\'s own 24h move', () {
      // $100 now after +10% means it was ~$90.91 → a ~$9.09 gain.
      final d = Portfolio(entries: [_holding(Network.solana, 100, 10)]).delta24h;
      expect(d, isNotNull);
      expect(d!.usd, closeTo(9.0909, 0.001));
      expect(d.pct, closeTo(10.0, 0.001));
    });

    test('weights each asset by how much is held, not a naive average', () {
      // Equal current value, +10% and -10%: the loser had a larger prior
      // value, so the portfolio is net *down* ~1% — not flat.
      final d = Portfolio(entries: [
        _holding(Network.solana, 100, 10),
        _holding(Network.ethereum, 100, -10),
      ]).delta24h;
      expect(d!.pct, closeTo(-1.0, 0.001));
      expect(d.usd, lessThan(0));
    });

    test('ignores assets missing a price or a 24h figure', () {
      final d = Portfolio(entries: [
        _holding(Network.solana, 100, 10),
        const PortfolioEntry(
            network: Network.bitcoin, address: 'a', amount: 1), // no price
        _holding(Network.ethereum, 250, null), // no change
      ]).delta24h;
      expect(d!.pct, closeTo(10.0, 0.001)); // same as the lone Solana holding
    });

    test('skips a -100% wipeout so it never divides by zero', () {
      final d = Portfolio(entries: [
        _holding(Network.solana, 100, 10),
        _holding(Network.ethereum, 50, -100),
      ]).delta24h;
      expect(d!.pct, closeTo(10.0, 0.001));
      expect(d.usd.isFinite, isTrue);
    });
  });
}
