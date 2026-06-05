import 'package:flutter/material.dart';

/// A curated dApp entry. This is a static directory (not realtime) — the
/// realtime data on Discovery is the Trending token list. Each entry opens its
/// real site, so the links are functional rather than placeholder.
///
/// [chainId] uses the app's `Network.id` values ('solana', 'ethereum', 'base'…)
/// so the chain chips filter these client-side.
class Dapp {
  const Dapp({
    required this.name,
    required this.category,
    required this.url,
    required this.chainId,
    required this.mono,
    required this.accent,
    this.gradient,
  });

  final String name;
  final String category;
  final String url;
  final String chainId;
  final String mono;
  final Color accent;

  /// Two-stop brand background for Spotlight cards; null for the compact app
  /// rows. The card uses the darker stop as a solid fill.
  final List<Color>? gradient;

  /// The dApp's real logo, resolved from its domain via Google's favicon service
  /// (reliable for any site). Falls back to the [mono] monogram if it can't load.
  String get logoUrl =>
      'https://www.google.com/s2/favicons?domain=${Uri.parse(url).host}&sz=128';
}

/// Featured apps shown in the Spotlight carousel.
const spotlightDapps = <Dapp>[
  Dapp(
    name: 'Jupiter',
    category: 'DEX Aggregator',
    url: 'https://jup.ag',
    chainId: 'solana',
    mono: 'J',
    accent: Color(0xFF4FD4C4),
    gradient: [Color(0xFF2A4D44), Color(0xFF0E2722)],
  ),
  Dapp(
    name: 'Magic Eden',
    category: 'NFT Marketplace',
    url: 'https://magiceden.io',
    chainId: 'solana',
    mono: 'M',
    accent: Color(0xFFE42575),
    gradient: [Color(0xFF3A2050), Color(0xFF1A0E29)],
  ),
  Dapp(
    name: 'Aave',
    category: 'Lending',
    url: 'https://aave.com',
    chainId: 'ethereum',
    mono: 'A',
    accent: Color(0xFF5FB8C9),
    gradient: [Color(0xFF1E3A4D), Color(0xFF0C1F2A)],
  ),
  Dapp(
    name: 'Aerodrome',
    category: 'DeFi · Base',
    url: 'https://aerodrome.finance',
    chainId: 'base',
    mono: 'Æ',
    accent: Color(0xFF3FA0FF),
    gradient: [Color(0xFF16306B), Color(0xFF0A1730)],
  ),
];

/// Apps listed under "Popular apps".
const popularDapps = <Dapp>[
  Dapp(name: 'Drift', category: 'Perps · Solana', url: 'https://drift.trade', chainId: 'solana', mono: 'D', accent: Color(0xFF9A6BFF)),
  Dapp(name: 'Uniswap', category: 'DEX · Ethereum', url: 'https://app.uniswap.org', chainId: 'ethereum', mono: 'U', accent: Color(0xFFFF5BA8)),
  Dapp(name: 'Tensor', category: 'NFTs · Solana', url: 'https://www.tensor.trade', chainId: 'solana', mono: 'T', accent: Color(0xFF4FD4C4)),
  Dapp(name: 'Lido', category: 'Staking · Ethereum', url: 'https://lido.fi', chainId: 'ethereum', mono: 'L', accent: Color(0xFF3FA0FF)),
  Dapp(name: 'Pump.fun', category: 'Launchpad · Solana', url: 'https://pump.fun', chainId: 'solana', mono: 'P', accent: Color(0xFF2FD37E)),
  Dapp(name: 'Aerodrome', category: 'DeFi · Base', url: 'https://aerodrome.finance', chainId: 'base', mono: 'Æ', accent: Color(0xFF2151F5)),
];

/// A Browse shortcut tile. Each plays a small Lottie on a uniform tile, with
/// [icon] as a graceful fallback if the asset can't load.
class BrowseCategory {
  const BrowseCategory({
    required this.label,
    required this.icon,
    required this.lottie,
  });
  final String label;
  final IconData icon;

  /// Lottie asset shown in the tile; [icon] renders instead if it fails.
  final String lottie;
}

const browseCategories = <BrowseCategory>[
  BrowseCategory(
      label: 'Swap', icon: Icons.swap_horiz, lottie: 'assets/lotties/swap.json'),
  BrowseCategory(
      label: 'NFTs',
      icon: Icons.image_outlined,
      lottie: 'assets/lotties/nfts.json'),
  BrowseCategory(
      label: 'Stake',
      icon: Icons.layers_outlined,
      lottie: 'assets/lotties/stake.json'),
  BrowseCategory(
      label: 'Bridge',
      icon: Icons.alt_route,
      lottie: 'assets/lotties/bridge.json'),
  BrowseCategory(
      label: 'Games',
      icon: Icons.sports_esports_outlined,
      lottie: 'assets/lotties/games.json'),
  BrowseCategory(
      label: 'Earn',
      icon: Icons.trending_up,
      lottie: 'assets/lotties/earn.json'),
];
