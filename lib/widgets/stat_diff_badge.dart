// Ported from style.css's @keyframes diffPop + .stat-diff — a "+2"/"-3" that
// pops in, holds, and fades on its own. CSS uses ease-out (interpolated
// keyframes, unlike the stepped power-on flicker), reproduced here with
// piecewise-linear interpolation between the same keyframe stops.
import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';

class StatDiffBadge extends StatelessWidget {
  final int diff;
  /// 0.0-1.0 progress through the 1.8s pop/fade.
  final double progress;

  const StatDiffBadge({super.key, required this.diff, required this.progress});

  // (threshold, opacity, translateY in logical pixels)
  static const _keyframes = <(double, double, double)>[
    (0.0, 0.0, 3.0),
    (0.15, 1.0, 0.0),
    (0.75, 1.0, 0.0),
    (1.0, 0.0, -8.0),
  ];

  (double opacity, double translateY) _valueAt(double t) {
    for (var i = 0; i < _keyframes.length - 1; i++) {
      final (t0, op0, y0) = _keyframes[i];
      final (t1, op1, y1) = _keyframes[i + 1];
      if (t >= t0 && t <= t1) {
        final span = t1 - t0;
        final localT = span == 0 ? 0.0 : (t - t0) / span;
        return (
          op0 + (op1 - op0) * localT,
          y0 + (y1 - y0) * localT,
        );
      }
    }
    return (0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final (opacity, translateY) = _valueAt(progress.clamp(0.0, 1.0));
    final sign = diff > 0 ? '+' : '';
    final style = diff > 0 ? AppTheme.statDiffUp : AppTheme.statDiffDown;
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, translateY),
          child: Text('$sign$diff', style: style),
        ),
      ),
    );
  }
}
