// Crew and drones are raw counts, not 0-100 gauges, so they get a plain
// number line rather than a bar (see StatRow) — ported from style.css's
// .count-row. The value sits at the same horizontal position StatRow's bar
// starts at (same label-column width + gap), matching the web version's
// shared grid-template-columns trick, so the two rows visually line up
// without a magic gap number.
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'stat_diff_badge.dart';

class CountRow extends StatefulWidget {
  final String label;
  final int value;

  const CountRow({super.key, required this.label, required this.value});

  @override
  State<CountRow> createState() => _CountRowState();
}

class _CountRowState extends State<CountRow> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant CountRow oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(width: 108, child: Text(widget.label, style: AppTheme.meta)),
          const SizedBox(width: 10),
          Text('${widget.value}', style: AppTheme.eventText.copyWith(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
          if (_diff != null) ...[
            const SizedBox(width: 6),
            AnimatedBuilder(
              animation: _diffController,
              builder: (context, _) => StatDiffBadge(diff: _diff!, progress: _diffController.value),
            ),
          ],
        ],
      ),
    );
  }
}
