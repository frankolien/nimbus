import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A custom numeric keypad (0–9, decimal, backspace) for amount entry, so the
/// large amount display stays visible instead of being covered by the system
/// keyboard.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onKey,
    required this.onBackspace,
  });

  /// Receives a single character: '0'–'9' or '.'.
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final k in row)
                Expanded(
                  child: _Key(
                    label: k,
                    onKey: onKey,
                    onBackspace: onBackspace,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.onKey,
    required this.onBackspace,
  });

  final String label;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.lightImpact();
        if (isBackspace) {
          onBackspace();
        } else {
          onKey(label);
        }
      },
      child: SizedBox(
        height: 62,
        child: Center(
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, size: 22, color: NB.text)
              : Text(label,
                  style: NB.font(25, weight: FontWeight.w600, color: NB.text)),
        ),
      ),
    );
  }
}
