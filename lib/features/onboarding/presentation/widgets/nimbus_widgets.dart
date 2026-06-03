import 'package:flutter/material.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// The angular orange "swift" brand mark, optionally on a dark rounded disc.
class NimbusLogo extends StatelessWidget {
  const NimbusLogo({super.key, this.size = 64, this.disc = true});

  final double size;
  final bool disc;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: disc ? size * 0.62 : size,
      height: disc ? size * 0.62 : size,
      child: CustomPaint(painter: _MarkPainter()),
    );
    if (!disc) return mark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.34),
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.6),
          radius: 1.2,
          colors: [Color(0xFF1B1D33), Color(0xFF121325)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x0FFFFFFF), blurRadius: 0, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: mark,
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100.0;
    Path p(List<Offset> pts) {
      final path = Path()..moveTo(pts.first.dx * s, pts.first.dy * s);
      for (final pt in pts.skip(1)) {
        path.lineTo(pt.dx * s, pt.dy * s);
      }
      return path..close();
    }

    final blade = p(const [
      Offset(26, 74),
      Offset(74, 26),
      Offset(62, 49),
      Offset(44, 60),
    ]);
    canvas.drawPath(
      blade,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [NB.markFrom, NB.markTo],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      p(const [
        Offset(44, 60),
        Offset(66.5, 45),
        Offset(60, 61),
        Offset(39, 75),
      ]),
      Paint()..color = NB.markWedge,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Nimbus" wordmark.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 22, this.color = NB.text});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        'Nimbus',
        style: NB.font(size, weight: FontWeight.w700, color: color, letterSpacing: -0.3),
      );
}

enum NbBtnVariant { primary, blue, ghost, outline, text }

/// The Nimbus button — 56px, 16-radius, press-scale, variant styling.
class NbButton extends StatefulWidget {
  const NbButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = NbBtnVariant.primary,
    this.enabled = true,
    this.leading,
  });

  final String label;
  final VoidCallback? onTap;
  final NbBtnVariant variant;
  final bool enabled;
  final Widget? leading;

  @override
  State<NbButton> createState() => _NbButtonState();
}

class _NbButtonState extends State<NbButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled || widget.onTap == null;
    final v = widget.variant;

    Color? bg;
    Gradient? gradient;
    Color fg = NB.text;
    BoxBorder? border;
    List<BoxShadow>? shadow;

    switch (v) {
      case NbBtnVariant.primary:
        gradient = NB.primaryGradient;
        shadow = disabled ? null : NB.orangeGlow;
      case NbBtnVariant.blue:
        bg = NB.blue;
      case NbBtnVariant.ghost:
        bg = NB.surface2;
      case NbBtnVariant.outline:
        bg = Colors.transparent;
        border = Border.all(color: NB.borderHi, width: 1.5);
      case NbBtnVariant.text:
        bg = Colors.transparent;
        fg = NB.text2;
    }

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: disabled ? 0.4 : 1,
          duration: const Duration(milliseconds: 180),
          child: Container(
            height: v == NbBtnVariant.text ? 44 : 56,
            decoration: BoxDecoration(
              color: bg,
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              border: border,
              boxShadow: shadow,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
                Text(widget.label,
                    style: NB.font(16, weight: FontWeight.w700, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen header with a back chip and optional help chip.
class NbHeader extends StatelessWidget {
  const NbHeader({super.key, this.onBack, this.showHelp = true, this.onHelp});
  final VoidCallback? onBack;
  final bool showHelp;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _chip(const Icon(Icons.arrow_back_ios_new, size: 18, color: NB.text), onBack),
          if (showHelp)
            _chip(const Icon(Icons.headset_mic_outlined, size: 18, color: NB.text2), onHelp)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _chip(Widget child, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: NB.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      );
}

/// Six-dot passcode indicator; pass [shake] to nudge it on a wrong code.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, this.length = 6});
  final int filled;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final on = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? NB.orange : Colors.transparent,
            border: on ? null : Border.all(color: NB.surface3, width: 2),
          ),
        );
      }),
    );
  }
}

/// Numeric keypad (1–9, 0, delete). Calls [onKey] with the digit, [onDelete]
/// for backspace.
class NbKeypad extends StatelessWidget {
  const NbKeypad({super.key, required this.onKey, required this.onDelete});
  final ValueChanged<int> onKey;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.7,
      padding: const EdgeInsets.only(top: 22),
      children: [
        for (var n = 1; n <= 9; n++) _Key(label: '$n', onTap: () => onKey(n)),
        const SizedBox.shrink(),
        _Key(label: '0', onTap: () => onKey(0)),
        _Key(
          onTap: onDelete,
          child: const Icon(Icons.backspace_outlined, size: 24, color: NB.text2),
        ),
      ],
    );
  }
}

class _Key extends StatefulWidget {
  const _Key({this.label, this.child, required this.onTap});
  final String? label;
  final Widget? child;
  final VoidCallback onTap;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _p = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) => setState(() => _p = false),
      onTapCancel: () => setState(() => _p = false),
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _p ? NB.surface3 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: widget.child ??
            Text(widget.label!,
                style: NB.font(26, weight: FontWeight.w600, color: NB.text)),
      ),
    );
  }
}

/// Soft ambient radial glow used behind hero content.
class AmbientGlow extends StatelessWidget {
  const AmbientGlow({
    super.key,
    this.color = NB.orange,
    this.size = 600,
    this.opacity = 0.28,
  });
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
            stops: const [0,1.95],
          ),
        ),
      ),
    );
  }
}
