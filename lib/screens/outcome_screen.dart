// Ported from game.js's renderOutcome.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/game_state.dart';
import '../state/app_screen_controller.dart';
import '../state/run_screen.dart';
import '../state/run_session_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/habitat_stats_bar.dart';
import '../widgets/hud_top.dart';
import '../widgets/nav_button.dart';
import '../widgets/nav_row.dart';

class OutcomeScreenView extends ConsumerWidget {
  final GameState gameState;
  final OutcomeRunScreen screen;

  const OutcomeScreenView({super.key, required this.gameState, required this.screen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(runSessionControllerProvider.notifier);
    final appController = ref.read(appScreenControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HudTop(cycle: gameState.cycle, onMainMenu: appController.showMenu),
        HabitatStatsBar(gameState: gameState, powerOn: false),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(screen.text, style: AppTheme.eventText.copyWith(fontStyle: FontStyle.italic)),
              NavRow(leading: [NavButton(label: 'Continue', onPressed: controller.continueFromOutcome)]),
            ],
          ),
        ),
      ],
    );
  }
}
