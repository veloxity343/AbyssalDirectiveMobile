// The menu's inline "are you sure" box when starting a new game over an
// existing save — ported from style.css's .confirm-inline.
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'nav_button.dart';

class ConfirmInline extends StatelessWidget {
  final String text;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmInline({super.key, required this.text, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: AppTheme.meta.copyWith(fontSize: 13.1, height: 1.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              NavButton(label: 'Yes, seal the hull!', onPressed: onConfirm),
              NavButton(label: 'Cancel', onPressed: onCancel),
            ],
          ),
        ],
      ),
    );
  }
}
