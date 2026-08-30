// Ported 1:1 from the web prototype's style.css :root custom properties.
import 'package:flutter/widgets.dart';

class AppColors {
  AppColors._();

  static const bgDeep = Color(0xFF041018);
  static const bgPanel = Color(0xFF0A1F2B);
  static const line = Color(0xFF163243);
  static const text = Color(0xFFD7E8EC);
  static const textDim = Color(0xFF7FA0AB);
  static const accent = Color(0xFF2FB8B0);
  static const warn = Color(0xFFE0A83E);
  static const danger = Color(0xFFD1544A);

  // The intro card renders over a paper photo (assets/paper.jpg in the web
  // version — not carried over here; see app_theme.dart's header) with dark,
  // ink-like text colors instead of the usual dark-panel palette above.
  static const paperInk = Color(0xFF16100A);
  static const paperHeading = Color(0xFF241A0E);
  static const paperStatusText = Color(0xFF6B2418);
  static const paperStatusBorder = Color(0xA66B2418); // rgba(107,36,24,0.65)
  static const paperNavText = Color(0xB3322819); // rgba(50,40,25,0.7)
  static const paperNavBorder = Color(0x59322819); // rgba(50,40,25,0.35)
}
