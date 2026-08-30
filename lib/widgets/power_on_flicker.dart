// Ported from style.css's @keyframes statFlicker + .poweron .stat. CSS uses
// steps(1, end) timing — each keyframe's opacity holds instantly until the
// next one, no interpolation between them — which this reproduces by
// picking the highest crossed threshold each frame rather than lerping.
import 'package:flutter/widgets.dart';

class PowerOnFlicker extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const PowerOnFlicker({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<PowerOnFlicker> createState() => _PowerOnFlickerState();
}

class _PowerOnFlickerState extends State<PowerOnFlicker> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // (threshold in [0,1] of the 0.7s duration, opacity held from that point)
  static const _keyframes = <(double, double)>[
    (0.0, 0.0),
    (0.08, 1.0),
    (0.10, 0.15),
    (0.18, 1.0),
    (0.22, 0.3),
    (0.30, 1.0),
    (1.0, 1.0),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  double _opacityFor(double t) {
    var value = 0.0;
    for (final (threshold, opacity) in _keyframes) {
      if (t >= threshold) {
        value = opacity;
      } else {
        break;
      }
    }
    return value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(opacity: _opacityFor(_controller.value), child: child),
      child: widget.child,
    );
  }
}
