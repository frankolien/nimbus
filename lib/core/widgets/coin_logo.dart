import 'package:flutter/material.dart';

import '../../features/wallet/domain/entities/network.dart';
import '../theme/nimbus_theme.dart';

/// A circular coin/chain logo. Loads the official artwork from the TrustWallet
/// assets CDN and falls back to a branded monogram disc while loading or if the
/// image is unavailable — so the UI never shows a broken image.
class CoinLogo extends StatelessWidget {
  const CoinLogo({super.key, required this.network, this.size = 42});

  final Network network;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = _Monogram(network: network, size: size);
    final url = CoinVisuals.logoUrl(network);
    if (url == null) return fallback;

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({required this.network, required this.size});
  final Network network;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CoinVisuals.brandColor(network),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        network.nativeSymbol,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.26,
        ),
      ),
    );
  }
}

/// Per-network presentation data (brand color + logo source).
abstract final class CoinVisuals {
  static const _brand = <String, Color>{
    'bitcoin': Color(0xFFF7931A),
    'ethereum': Color(0xFF627EEA),
    'polygon': Color(0xFF8247E5),
    'base': Color(0xFF0052FF),
    'solana': Color(0xFF9945FF),
    'sui': Color(0xFF4DA2FF),
  };

  static Color brandColor(Network n) => _brand[n.id] ?? NB.surface3;

  /// TrustWallet assets CDN folder per network.
  static const _logoChain = <String, String>{
    'bitcoin': 'bitcoin',
    'ethereum': 'ethereum',
    'polygon': 'polygon',
    'base': 'base',
    'solana': 'solana',
    'sui': 'sui',
  };

  static String? logoUrl(Network n) {
    final chain = _logoChain[n.id];
    if (chain == null) return null;
    return 'https://raw.githubusercontent.com/trustwallet/assets/master/'
        'blockchains/$chain/info/logo.png';
  }
}
