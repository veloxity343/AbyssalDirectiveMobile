// Endings are checked in priority order every cycle (once checkEnding exists
// in engine.dart). Stat-zero endings cover the "you lost" cases; scripted
// ones (via flags) cover corporate-driven win/loss outcomes. Player-chosen
// settlement endings (see settleAtSite) are computed dynamically from
// discovered sites, not listed here.
//
// Ported 1:1 from the web prototype's src/content/endings.js.

import '../engine/game_state.dart';

class Ending {
  final String id;
  final String title;
  final int priority;
  final String text;
  final bool Function(GameState state) condition;
  const Ending({
    required this.id,
    required this.title,
    required this.priority,
    required this.text,
    required this.condition,
  });
}

final List<Ending> endings = [
  Ending(
    id: "implosion",
    title: "The Pressure Wins",
    priority: 100,
    text:
        "A seam gives somewhere below Sector 2. There is no groan of warning, only a sound like the ocean clearing its throat, and then the sound of nothing at all.",
    condition: (s) => s.stats["hull"]! <= 0,
  ),
  Ending(
    id: "suffocation",
    title: "Silent Depths",
    priority: 100,
    text:
        "The scrubbers stop, and the habitat goes quiet in a way that has nothing to do with sound. You log the last entry by feel, in the dark, because the lights went first.",
    condition: (s) => s.stats["oxygen"]! <= 0,
  ),
  Ending(
    id: "madness",
    title: "Whispers in the Dark",
    priority: 100,
    text:
        "Someone unseals an airlock they shouldn't have. Nobody stops them. By the time you understand why, understanding doesn't help anymore.",
    condition: (s) => s.stats["sanity"]! <= 0,
  ),
  Ending(
    id: "starvation",
    title: "Empty Larders",
    priority: 100,
    text: "The ration counts stop meaning anything. What the crew decides to do about that is not something you write down.",
    condition: (s) => s.stats["supplies"]! <= 0,
  ),
  Ending(
    id: "no_crew",
    title: "Nothing Left to Direct",
    priority: 100,
    text:
        "The last name comes off the crew manifest. The habitat is still running — lights on, air cycling, hull intact — and there is no one left aboard it for any of that to matter to.",
    condition: (s) => s.crewCount <= 0,
  ),
  Ending(
    id: "cut_loose",
    title: "Cut Loose",
    priority: 90,
    text:
        "Corporate stops answering hails. Somewhere in a boardroom above the waves, the habitat is quietly reclassified as a loss. No rescue is coming, and none was ever really promised.",
    condition: (s) => s.stats["favour"]! <= 0 && s.cycle > 5,
  ),
  Ending(
    id: "ascension",
    title: "Ascension",
    priority: 80,
    text:
        "The retrieval sub docks on schedule, for once. As the habitat's lights recede beneath you, you find you're not sure if what you feel is relief.",
    condition: (s) => (s.flags["rescueApproved"] ?? false) && s.stats["favour"]! >= 60,
  ),
  Ending(
    id: "endurance",
    title: "Endurance",
    priority: 10,
    text:
        "The habitat is still down here, still breathing, still yours. Whatever comes next, you made it further than anyone above the waves expected.",
    condition: (s) => false, // reached only via the cycle-limit fallback in engine.dart
  ),
];
