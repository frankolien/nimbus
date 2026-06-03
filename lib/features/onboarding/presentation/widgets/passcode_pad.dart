import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';
import 'nimbus_widgets.dart';

/// A full passcode entry block: title, subtitle, 6 dots, numeric keypad, with a
/// built-in shake on error. Drive errors from the parent via a [GlobalKey]:
///
///   final padKey = GlobalKey<PasscodePadState>();
///   ...
///   padKey.currentState?.shakeAndClear();
class PasscodePad extends StatefulWidget {
  const PasscodePad({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onCompleted,
    this.errorText,
    this.length = 6,
    this.busy = false,
  });

  final String title;
  final String subtitle;

  /// Called when [length] digits have been entered.
  final ValueChanged<String> onCompleted;

  /// Shown in red instead of [subtitle] when set (e.g. "Codes didn't match").
  final String? errorText;
  final int length;
  final bool busy;

  @override
  State<PasscodePad> createState() => PasscodePadState();
}

class PasscodePadState extends State<PasscodePad>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  /// Clear the entered digits with a shake — call after a wrong/ mismatched code.
  void shakeAndClear() {
    setState(() => _pin = '');
    _shake.forward(from: 0);
  }

  void clear() => setState(() => _pin = '');

  void _onKey(int n) {
    if (widget.busy || _pin.length >= widget.length) return;
    setState(() => _pin += '$n');
    if (_pin.length == widget.length) {
      // Defer so the last dot paints before the parent reacts.
      final value = _pin;
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) widget.onCompleted(value);
      });
    }
  }

  void _onDelete() {
    if (widget.busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title,
            style: NB.font(20, weight: FontWeight.w800, color: NB.text)),
        const SizedBox(height: 8),
        Text(
          error ?? widget.subtitle,
          textAlign: TextAlign.center,
          style: NB.font(13.5, color: error != null ? NB.red : NB.text2),
        ),
        const SizedBox(height: 28),
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final t = _shake.value;
            // Damped horizontal oscillation.
            final dx = t == 0 ? 0.0 : 9 * (1 - t) *
                (t < .2 ? -1 : t < .4 ? 1 : t < .6 ? -1 : t < .8 ? 1 : -1);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: PinDots(filled: _pin.length, length: widget.length),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: widget.busy ? 0.4 : 1,
          child: IgnorePointer(
            ignoring: widget.busy,
            child: NbKeypad(onKey: _onKey, onDelete: _onDelete),
          ),
        ),
      ],
    );
  }
}
