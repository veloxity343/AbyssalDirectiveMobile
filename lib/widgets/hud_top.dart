// Cycle counter + Main Menu link — ported from game.js's hudTopHtml().
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class HudTop extends StatelessWidget {
  final int cycle;
  final VoidCallback onMainMenu;

  const HudTop({super.key, required this.cycle, required this.onMainMenu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('CYCLE $cycle', style: AppTheme.cycleLabel),
          TextButton(
            onPressed: onMainMenu,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textDim,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Main Menu', style: TextStyle(fontSize: 12.8, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}
