// Ported from game.js's renderSiteScenario.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/game_state.dart';
import '../state/app_screen_controller.dart';
import '../state/run_screen.dart';
import '../state/run_session_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/anomaly_list.dart';
import '../widgets/app_card.dart';
import '../widgets/choice_button.dart';
import '../widgets/habitat_stats_bar.dart';
import '../widgets/hud_top.dart';
import '../widgets/site_stats_bar.dart';

class SiteScreenView extends ConsumerWidget {
  final GameState gameState;
  final SiteRunScreen screen;

  const SiteScreenView({super.key, required this.gameState, required this.screen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(runSessionControllerProvider.notifier);
    final appController = ref.read(appScreenControllerProvider.notifier);
    final site = screen.site;
    final lead = screen.isNewDiscovery
        ? "You've charted a possible foothold: ${site.name}."
        : "${site.name} is still out there, waiting on a decision.";

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
              Text(site.name, style: AppTheme.cardHeading),
              const SizedBox(height: 12),
              Text('$lead ${site.blurb}', style: AppTheme.eventText),
              const SizedBox(height: 14),
              Text(
                'PROJECTED CONDITIONS',
                style: AppTheme.meta.copyWith(fontSize: 12.5, letterSpacing: 1.1, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SiteStatsBar(site: site),
              AnomalyList(
                site: site,
                drones: gameState.drones,
                onExplore: (anomalyId) => controller.exploreAnomalyAction(site, anomalyId),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    ChoiceButton(
                      label: 'Settle Here — End the Directive',
                      onPressed: () => controller.settleAction(site),
                    ),
                    ChoiceButton(label: 'Not Yet — Keep Going', onPressed: controller.declineSite),
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
