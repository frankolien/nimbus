import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/discovery/data/discovery_service.dart';
import 'package:nimbus/features/discovery/domain/trending_token.dart';

void main() {
  group('TrendingToken.fromCoinGecko', () {
    test('parses a markets row', () {
      final t = TrendingToken.fromCoinGecko({
        'id': 'solana',
        'symbol': 'sol',
        'name': 'Solana',
        'image': 'https://img/sol.png',
        'current_price': 176.42,
        'price_change_percentage_24h': 4.2,
        'sparkline_in_7d': {
          'price': [1.0, 2.0, 3.0]
        },
      });
      expect(t.symbol, 'SOL'); // upper-cased
      expect(t.name, 'Solana');
      expect(t.imageUrl, 'https://img/sol.png');
      expect(t.price, 176.42);
      expect(t.change24h, 4.2);
      expect(t.isUp, isTrue);
      expect(t.sparkline, [1.0, 2.0, 3.0]);
    });

    test('tolerates missing fields', () {
      final t = TrendingToken.fromCoinGecko({'symbol': 'btc'});
      expect(t.symbol, 'BTC');
      expect(t.price, 0);
      expect(t.change24h, isNull);
      expect(t.sparkline, isEmpty);
      expect(t.imageUrl, '');
    });

    test('negative 24h change reads as down', () {
      final t = TrendingToken.fromCoinGecko(
          {'symbol': 'eth', 'price_change_percentage_24h': -0.8});
      expect(t.isUp, isFalse);
    });
  });

  group('DiscoveryService.categoryFor', () {
    test('all → no category; chains → ecosystem category', () {
      expect(DiscoveryService.categoryFor('all'), isNull);
      expect(DiscoveryService.categoryFor('solana'), 'solana-ecosystem');
      expect(DiscoveryService.categoryFor('ethereum'), 'ethereum-ecosystem');
      expect(DiscoveryService.categoryFor('bitcoin'), 'bitcoin-ecosystem');
    });
  });
}
