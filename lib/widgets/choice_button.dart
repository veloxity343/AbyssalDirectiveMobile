// Primary decision button — ported from style.css's .choice-btn. Stays
// full-size, unlike NavButton's smaller/quieter secondary style.
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ChoiceButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const ChoiceButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.text,
            disabledForegroundColor: AppColors.text.withOpacity(0.35),
            side: BorderSide(color: onPressed == null ? AppColors.accent.withOpacity(0.35) : AppColors.accent),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.centerLeft,
            textStyle: const TextStyle(fontSize: 15.2),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
