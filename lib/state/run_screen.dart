// What the gameplay area is currently showing — the Flutter-side analog of
// game.js calling one of its render* functions. A sealed class instead of
// an enum + fields because each screen carries different data.

import '../content/events/event_schema.dart';
import '../engine/game_state.dart';

sealed class RunScreen {
  const RunScreen();
}

/// Before a game has been started or resumed.
class IdleRunScreen extends RunScreen {
  const IdleRunScreen();
}

class EventRunScreen extends RunScreen {
  final GameEvent event;
  /// True only on a fresh (non-resumed) run's very first screen — triggers
  /// the habitat stat bar's one-time power-on flicker.
  final bool powerOn;
  const EventRunScreen({required this.event, required this.powerOn});
}

class OutcomeRunScreen extends RunScreen {
  final String text;
  final bool? succeeded;
  const OutcomeRunScreen({required this.text, required this.succeeded});
}

class SiteRunScreen extends RunScreen {
  final SiteInstance site;
  final bool isNewDiscovery;
  const SiteRunScreen({required this.site, required this.isNewDiscovery});
}

/// `paragraphs` already includes the closing survival tally as its last
/// entry — see RunSessionController._finishRun. The widget reveals them
/// progressively; this holds the full, final list either way.
class EndingRunScreen extends RunScreen {
  final String title;
  final List<String> paragraphs;
  const EndingRunScreen({required this.title, required this.paragraphs});
}
