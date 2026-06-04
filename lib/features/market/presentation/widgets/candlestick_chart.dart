import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../data/market_service.dart';

/// A lightweight candlestick chart with a volume strip, right-hand price axis,
/// and a last-price marker line. Pure CustomPaint — no chart dependency.
class CandlestickChart extends StatelessWidget {
  const CandlestickChart({super.key, required this.candles, this.height = 280});

  final List<Candle> candles;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: candles.isEmpty
          ? const SizedBox.shrink()
          : CustomPaint(painter: _CandlePainter(candles)),
    );
  }
}

class _CandlePainter extends CustomPainter {
  _CandlePainter(this.candles);
  final List<Candle> candles;

  static const _rightPad = 54.0;
  static const _volRatio = 0.22; // fraction of height for volume strip

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _rightPad;

    var hi = candles.first.high, lo = candles.first.low, maxVol = 0.0;
    for (final c in candles) {
      if (c.high > hi) hi = c.high;
      if (c.low < lo) lo = c.low;
      if (c.volume > maxVol) maxVol = c.volume;
    }

    // Reserve a volume strip only when we actually have volume data; otherwise
    // candles use the full height.
    final hasVolume = maxVol > 0;
    final volTop = hasVolume ? size.height * (1 - _volRatio) : size.height;
    final priceH = volTop - (hasVolume ? 6 : 0);
    final range = (hi - lo).abs() < 1e-9 ? 1.0 : hi - lo;

    double y(double price) => priceH * (1 - (price - lo) / range);

    // Gridlines + right-axis price labels.
    final grid = Paint()
      ..color = NB.borderHi.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    const rows = 4;
    for (var i = 0; i <= rows; i++) {
      final price = hi - range * i / rows;
      final yy = y(price);
      canvas.drawLine(Offset(0, yy), Offset(chartW, yy), grid);
      _label(canvas, _fmt(price), Offset(chartW + 6, yy - 6), NB.text3);
    }

    final n = candles.length;
    final slot = chartW / n;
    final bodyW = (slot * 0.62).clamp(1.5, 14.0);

    for (var i = 0; i < n; i++) {
      final c = candles[i];
      final cx = slot * i + slot / 2;
      final color = c.isUp ? NB.green : NB.red;
      final paint = Paint()..color = color;

      // Wick.
      canvas.drawLine(
        Offset(cx, y(c.high)),
        Offset(cx, y(c.low)),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );
      // Body.
      final top = y(c.open > c.close ? c.open : c.close);
      final bot = y(c.open > c.close ? c.close : c.open);
      final rect = Rect.fromLTRB(cx - bodyW / 2, top, cx + bodyW / 2,
          (bot - top).abs() < 1 ? top + 1 : bot);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(1.5)), paint);

      // Volume.
      if (maxVol > 0) {
        final vh = (size.height - volTop) * (c.volume / maxVol);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(cx - bodyW / 2, size.height - vh, cx + bodyW / 2,
                size.height),
            const Radius.circular(1),
          ),
          Paint()..color = color.withValues(alpha: 0.28),
        );
      }
    }

    // Last-price marker line + pill.
    final last = candles.last;
    final ly = y(last.close);
    final markColor = last.isUp ? NB.green : NB.red;
    canvas.drawLine(
      Offset(0, ly),
      Offset(chartW, ly),
      Paint()
        ..color = markColor
        ..strokeWidth = 1,
    );
    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(chartW + 2, ly - 9, _rightPad - 2, 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(pill, Paint()..color = markColor);
    _label(canvas, _fmt(last.close), Offset(chartW + 6, ly - 6), Colors.white,
        bold: true);
  }

  void _label(Canvas canvas, String text, Offset at, Color color,
      {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  String _fmt(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    if (v >= 1) return v.toStringAsFixed(2);
    return v.toStringAsFixed(4);
  }

  @override
  bool shouldRepaint(covariant _CandlePainter old) => old.candles != candles;
}
