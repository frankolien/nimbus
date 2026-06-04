import 'package:flutter/material.dart';

import '../theme/nimbus_theme.dart';

/// A shimmering placeholder block used for skeleton loading states.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
  });

  /// A circular skeleton of [size].
  const Skeleton.circle(double size, {Key? key})
      : this(key: key, width: size, height: size, shape: BoxShape.circle);

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: const [NB.surface2, NB.surface3, NB.surface2],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlideGradient(_controller.value * 2 - 1),
          ).createShader(rect),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: NB.surface2,
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.circle
                  ? null
                  : BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}

/// Slides a gradient horizontally across the shader bounds.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.slide);
  final double slide;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}
