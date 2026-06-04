import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/portfolio/data/binance_price_stream.dart';
import 'package:nimbus/features/wallet/domain/entities/network.dart';

void main() {
  final symbolMap = BinancePriceStream.symbolMap(Network.values);

  String frame(String symbol, String price, String changePct) => jsonEncode({
        'stream': '${symbol.toLowerCase()}@ticker',
        'data': {'e': '24hrTicker', 's': symbol, 'c': price, 'P': changePct},
      });

  test('ETHUSDT maps to both Ethereum and Base', () {
    expect(symbolMap['ethusdt']!.toSet(),
        {Network.ethereum, Network.base});
  });

  test('parses price + 24h change for a ticker frame', () {
    final updates = BinancePriceStream.parseFrame(
        frame('SOLUSDT', '146.76', '-6.20'), symbolMap);
    final sol = updates[Network.solana]!;
    expect(sol.usd, 146.76);
    expect(sol.change24h, -6.20);
  });

  test('one ETH frame updates Ethereum and Base together', () {
    final updates =
        BinancePriceStream.parseFrame(frame('ETHUSDT', '1752.28', '-7.04'), symbolMap);
    expect(updates[Network.ethereum]!.usd, 1752.28);
    expect(updates[Network.base]!.usd, 1752.28);
    expect(updates[Network.base]!.change24h, -7.04);
  });

  test('ignores unknown symbols', () {
    final updates = BinancePriceStream.parseFrame(
        frame('DOGEUSDT', '0.1', '1.0'), symbolMap);
    expect(updates, isEmpty);
  });

  test('returns empty (never throws) for malformed frames', () {
    expect(BinancePriceStream.parseFrame('not json', symbolMap), isEmpty);
    expect(BinancePriceStream.parseFrame('{"data":null}', symbolMap), isEmpty);
    expect(BinancePriceStream.parseFrame('{"foo":1}', symbolMap), isEmpty);
  });

  test('handles a missing price gracefully', () {
    final raw = jsonEncode({
      'data': {'s': 'BTCUSDT', 'P': '2.0'} // no 'c'
    });
    expect(BinancePriceStream.parseFrame(raw, symbolMap), isEmpty);
  });
}
