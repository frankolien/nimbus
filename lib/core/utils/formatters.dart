import 'dart:math';

/// Display formatting for money, token amounts, and percentages.
///
/// Centralized so every screen renders numbers identically — no per-widget
/// copies of "add thousands separators" or "compact a big number".
abstract final class Fmt {
  /// `$1,234.56`
  static String usd(double value) {
    final s = value.toStringAsFixed(2);
    final parts = s.split('.');
    final withCommas = parts[0]
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '\$$withCommas.${parts[1]}';
  }

  /// A spot price: full USD above $1, more precision below (`$0.9912`).
  static String price(double value) =>
      value >= 1 ? usd(value) : '\$${value.toStringAsFixed(4)}';

  /// A market price that also reads micro-cap tokens well: `$176.42`, `$0.9912`,
  /// `$0.000031` — enough significant figures below a cent, trailing zeros
  /// trimmed.
  static String marketPrice(double value) {
    if (value >= 1) return usd(value);
    if (value <= 0) return '\$0';
    if (value >= 0.01) return '\$${_trimZeros(value.toStringAsFixed(4))}';
    final decimals = (-(log(value) / ln10)).ceil() + 2;
    return '\$${_trimZeros(value.toStringAsFixed(decimals.clamp(4, 12)))}';
  }

  static String _trimZeros(String s) => s.contains('.')
      ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
      : s;

  /// Compact USD for large figures: `$77.68M`, `$1.23B`. Null → `—`.
  static String compactUsd(double? value) {
    if (value == null) return '—';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '\$${(value / 1e3).toStringAsFixed(2)}K';
    return usd(value);
  }

  /// Compact plain number (e.g. circulating supply): `44.19K`. Null → `—`.
  static String compact(double? value) {
    if (value == null) return '—';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(0);
  }

  /// A token balance, trimming trailing zeros (`0.0207`, `1.5`, `0`).
  static String tokenAmount(double value) {
    if (value == 0) return '0';
    final s = value >= 1
        ? value.toStringAsFixed(4)
        : value.toStringAsFixed(6);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// Signed percentage: `+1.23%`, `-7.04%`.
  static String percent(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';

  /// A shortened address for display: `7xKXtg…2nQ9`. Keeps [head] leading and
  /// [tail] trailing characters around an ellipsis; returns short addresses
  /// unchanged.
  static String address(String value, {int head = 6, int tail = 4}) {
    if (value.length <= head + tail + 1) return value;
    return '${value.substring(0, head)}…${value.substring(value.length - tail)}';
  }
}
