// Top-level shell: the radial-gradient background + centered max-width
// column, ported from style.css's body/#app rules, wrapping whichever
// AppScreen is currently active.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/credits_screen.dart';
import 'screens/game_screen.dart';
import 'screens/history_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/privacy_screen.dart';
import 'state/app_screen.dart';
import 'state/app_screen_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Abyssal Directive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(appScreenControllerProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.3,
            colors: [Color(0xFF0D2836), AppColors.bgDeep],
            stops: [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                child: switch (screen) {
                  MenuAppScreen() => const MenuScreen(),
                  IntroAppScreen(directiveNumber: final n) => IntroScreen(directiveNumber: n),
                  HistoryAppScreen() => const HistoryScreen(),
                  CreditsAppScreen() => const CreditsScreen(),
                  PrivacyAppScreen() => const PrivacyScreen(),
                  GameAppScreen() => const GameScreen(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
