// One gauge row: label, 0-100 bar (colored by danger/warn/ok threshold,
// matching style.css's .stat.danger/.warn), value, and a floating diff badge
// that pops in whenever `value` changes between rebuilds. The diffing itself
// (comparing to the last-seen value) lives here, in this widget's own state
// — unlike the JS version, which tracked prevHabitatStats/prevSiteStats in
// the session/game state purely to support this. Flutter's declarative
// rebuilds make that unnecessary: this widget already gets called again
// with a new `value` when the underlying stat changes, so `didUpdateWidget`
// is all the diffing that's needed.
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'power_on_flicker.dart';
import 'stat_diff_badge.dart';

class StatRow extends StatefulWidget {
  final String label;
  final int value; // 0-100
  /// Non-null enables the power-on flicker-in, staggered by this delay.
  final Duration? powerOnDelay;

  const StatRow({super.key, required this.label, required this.value, this.powerOnDelay});

  @override
  State<StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<StatRow> with SingleTickerProviderStateMixin {
  late int _lastValue;
  int? _diff;
  late final AnimationController _diffController;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
    _diffController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  }

  @override
  void didUpdateWidget(covariant StatRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _lastValue) {
      final delta = widget.value - _lastValue;
      _lastValue = widget.value;
      setState(() => _diff = delta);
      _diffController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _diffController.dispose();
    super.dispose();
  }

  Color get _fillColor {
    if (widget.value <= 20) return AppColors.danger;
    if (widget.value <= 40) return AppColors.warn;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = widget.value.clamp(0, 100);
    Widget row = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 108,
                child: Text(widget.label, style: AppTheme.statLabel, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 6,
                    color: AppColors.line,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: clamped / 100,
                      child: Container(color: _fillColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 30,
                child: Text(
                  '${widget.value}',
                  textAlign: TextAlign.right,
                  style: AppTheme.statLabel.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (_diff != null)
            Positioned(
              right: -40,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _diffController,
                  builder: (context, _) => StatDiffBadge(diff: _diff!, progress: _diffController.value),
                ),
              ),
            ),
        ],
      ),
    );
    if (widget.powerOnDelay != null) {
      row = PowerOnFlicker(delay: widget.powerOnDelay!, child: row);
    }
    return row;
  }
}
