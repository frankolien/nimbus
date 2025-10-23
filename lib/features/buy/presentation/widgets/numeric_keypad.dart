import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onClearPressed;

  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 12),

          // Row 2: 4, 5, 6
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 12),

          // Row 3: 7, 8, 9
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 12),

          // Row 4: Clear, 0, Backspace
          Row(
            children: [
              Expanded(child: _buildKeypadButton('C', onClearPressed)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildKeypadButton('0', () => onDigitPressed('0'))),
              const SizedBox(width: 12),
              Expanded(child: _buildKeypadButton('⌫', onBackspacePressed)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      children: digits.map((digit) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildKeypadButton(digit, () => onDigitPressed(digit)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String text, VoidCallback onPressed) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
