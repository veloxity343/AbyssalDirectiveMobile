// The Flutter/Riverpod replacement for game.js's render() dispatch to
// renderEvent/renderOutcome/renderSiteScenario/renderEnding — switches on
// RunSessionController's current screen and shows the matching view.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/run_screen.dart';
import '../state/run_session_controller.dart';
import 'ending_screen.dart';
import 'event_screen.dart';
import 'outcome_screen.dart';
import 'site_screen.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(runSessionControllerProvider);
    final screen = session.screen;

    return switch (screen) {
      IdleRunScreen() => const SizedBox.shrink(), // transient: never actually visible
      EventRunScreen() => EventScreenView(gameState: session.gameState!, screen: screen),
      OutcomeRunScreen() => OutcomeScreenView(gameState: session.gameState!, screen: screen),
      SiteRunScreen() => SiteScreenView(gameState: session.gameState!, screen: screen),
      EndingRunScreen() => EndingScreenView(screen: screen),
    };
  }
}
