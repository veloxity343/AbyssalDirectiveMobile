// Secondary navigation button (Continue / Back / Skip) — deliberately
// smaller and quieter than ChoiceButton, ported from style.css's .nav-btn.
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NavButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const NavButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDim,
        side: const BorderSide(color: AppColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        textStyle: const TextStyle(fontSize: 12.8),
      ),
      child: Text(label),
    );
  }
}
