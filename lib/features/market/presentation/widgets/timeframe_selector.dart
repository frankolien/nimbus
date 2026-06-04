import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import '../../data/market_service.dart';

/// Segmented selector for the chart timeframe (15m / 1H / 4H / 1D).
class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final Timeframe selected;
  final ValueChanged<Timeframe> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final tf in Timeframe.values)
          GestureDetector(
            onTap: () => onSelect(tf),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: tf == selected ? NB.surface2 : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tf.label,
                  style: NB.font(13.5,
                      weight: FontWeight.w700,
                      color: tf == selected ? NB.text : NB.text3)),
            ),
          ),
      ],
    );
  }
}
