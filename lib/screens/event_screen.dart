// Ported from game.js's renderEvent.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/game_state.dart';
import '../state/app_screen_controller.dart';
import '../state/run_screen.dart';
import '../state/run_session_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/choice_button.dart';
import '../widgets/habitat_stats_bar.dart';
import '../widgets/hud_top.dart';

class EventScreenView extends ConsumerWidget {
  final GameState gameState;
  final EventRunScreen screen;

  const EventScreenView({super.key, required this.gameState, required this.screen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(runSessionControllerProvider.notifier);
    final appController = ref.read(appScreenControllerProvider.notifier);
    final event = screen.event;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HudTop(cycle: gameState.cycle, onMainMenu: appController.showMenu),
        HabitatStatsBar(gameState: gameState, powerOn: screen.powerOn),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(event.title, style: AppTheme.cardHeading),
              const SizedBox(height: 12),
              Text(event.text, style: AppTheme.eventText),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    for (final choice in event.choices)
                      ChoiceButton(
                        label: choice.label,
                        onPressed: () => controller.resolveChoiceAction(event, choice),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
