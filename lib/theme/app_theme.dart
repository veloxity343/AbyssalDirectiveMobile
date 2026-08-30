// Ported from style.css. Two things could not be carried over and need
// follow-up once this is buildable on a real device:
//   1. The body font is "Iowan Old Style"/Georgia in CSS — neither ships
//      with Flutter by default. This uses the platform serif fallback via
//      FontWeight/serif family hints; bundle a matching font asset (or pick
//      a close Google Font) for a pixel-accurate match.
//   2. The intro card's background is a paper photo (assets/paper.jpg in
//      the web repo) — that image file was never read into this session,
//      so it isn't ported. intro_screen.dart uses a flat paperInk-adjacent
//      color instead for now; drop the real photo into assets/ and wire it
//      up as a DecorationImage when available.
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const fontFamily = 'Georgia';

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.bgPanel,
        primary: AppColors.accent,
        error: AppColors.danger,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }

  // Text styles keyed to their CSS class names, so screens can stay close to
  // the original markup's intent when porting.
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    letterSpacing: 2.2, // 0.12em @ 32px body
    color: AppColors.accent,
    fontWeight: FontWeight.w600,
  );

  static const subtitle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textDim,
    fontStyle: FontStyle.italic,
  );

  static const cardHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.8, // 1.3rem
    color: AppColors.accent,
    fontWeight: FontWeight.w600,
  );

  static const eventText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.8, // 1.05rem
    height: 1.6,
    color: AppColors.text,
  );

  static const meta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.6, // 0.85rem
    color: AppColors.textDim,
  );

  static const cycleLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.6,
    letterSpacing: 1.5, // 0.15em
    color: AppColors.textDim,
  );

  static const statLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.8, // 0.8rem
    color: AppColors.textDim,
  );

  static const statDiffUp = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  static const statDiffDown = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.bold,
    color: AppColors.danger,
  );
}
