// Converts between decimal strings and integer base units without going
// through doubles, so "0.1" SOL is exactly 100000000 lamports.

/// Parses a decimal string like "1.25" into base units for an asset with
/// [decimals] fractional digits. Returns null if the string isn't a plain
/// non-negative decimal or has more fractional digits than the asset allows.
BigInt? toBaseUnits(String value, int decimals) {
  final s = value.trim();
  if (!RegExp(r'^\d*(\.\d*)?$').hasMatch(s) || s.isEmpty || s == '.') {
    return null;
  }
  final parts = s.split('.');
  final whole = parts[0].isEmpty ? '0' : parts[0];
  var frac = parts.length > 1 ? parts[1] : '';
  frac = frac.replaceFirst(RegExp(r'0+$'), '');
  if (frac.length > decimals) return null;
  final fracUnits =
      frac.isEmpty ? BigInt.zero : BigInt.parse(frac.padRight(decimals, '0'));
  return BigInt.parse(whole) * BigInt.from(10).pow(decimals) + fracUnits;
}

/// Formats base units as a decimal string with trailing zeros removed.
String fromBaseUnits(BigInt units, int decimals) {
  final negative = units.isNegative;
  final digits = units.abs().toString().padLeft(decimals + 1, '0');
  final whole = digits.substring(0, digits.length - decimals);
  final frac = digits
      .substring(digits.length - decimals)
      .replaceFirst(RegExp(r'0+$'), '');
  final out = frac.isEmpty ? whole : '$whole.$frac';
  return negative ? '-$out' : out;
}

/// Rounds a display double down to [decimals] places as a decimal string.
/// Used only for UI conversions (fiat to asset, cached balances); the result
/// still goes through [toBaseUnits] before sending.
String doubleToDecimalString(double value, int decimals) {
  if (value <= 0 || value.isNaN || value.isInfinite) return '0';
  final fixed = value.toStringAsFixed(decimals + 2);
  final dot = fixed.indexOf('.');
  final truncated = dot < 0
      ? fixed
      : fixed.substring(0, (dot + 1 + decimals).clamp(0, fixed.length));
  final units = toBaseUnits(truncated, decimals) ?? BigInt.zero;
  return fromBaseUnits(units, decimals);
}
