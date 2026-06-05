import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/nimbus_theme.dart';

/// A slide-to-confirm control: drag the thumb to the far edge to fire
/// [onConfirmed]. Locks and shows [busyLabel] while [busy] is true, and resets
/// itself if an attempt finishes without navigating away (e.g. a failed send),
/// so the user can slide again. Used for the final transfer confirmation so it
/// can't trigger on an accidental tap.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.busy = false,
    this.busyLabel = 'Confirming…',
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool busy;
  final String busyLabel;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  static const _height = 58.0;
  static const _thumb = 50.0;
  static const _pad = 4.0;

  double _dx = 0;
  bool _dragging = false;
  bool _fired = false;

  @override
  void didUpdateWidget(SlideToConfirm old) {
    super.didUpdateWidget(old);
    // Attempt finished but we're still on screen (e.g. it failed) — reset.
    if (old.busy && !widget.busy) {
      setState(() {
        _dx = 0;
        _fired = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final maxDx = c.maxWidth - _thumb - _pad * 2;
      final progress = maxDx <= 0 ? 0.0 : (_dx / maxDx).clamp(0.0, 1.0);
      return Container(
        height: _height,
        decoration: BoxDecoration(
          color: NB.surface2,
          borderRadius: BorderRadius.circular(_height / 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - progress).clamp(0.25, 1.0),
              child: Text(widget.busy ? widget.busyLabel : widget.label,
                  style: NB.font(15, weight: FontWeight.w700, color: NB.text)),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: _dragging ? 0 : 200),
              curve: Curves.easeOut,
              left: _pad + (widget.busy ? maxDx : _dx),
              top: _pad,
              child: GestureDetector(
                onHorizontalDragStart:
                    widget.busy ? null : (_) => setState(() => _dragging = true),
                onHorizontalDragUpdate: widget.busy
                    ? null
                    : (d) => setState(
                        () => _dx = (_dx + d.delta.dx).clamp(0.0, maxDx)),
                onHorizontalDragEnd: widget.busy ? null : (_) => _end(maxDx),
                child: _ThumbCircle(busy: widget.busy),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _end(double maxDx) {
    if (!_fired && _dx >= maxDx * 0.88) {
      _fired = true;
      _dx = maxDx;
      HapticFeedback.mediumImpact();
      widget.onConfirmed();
    } else {
      _dx = 0;
    }
    setState(() => _dragging = false);
  }
}

class _ThumbCircle extends StatelessWidget {
  const _ThumbCircle({required this.busy});
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(color: NB.orange, shape: BoxShape.circle),
      child: busy
          ? const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: Colors.white),
            )
          : const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
    );
  }
}
