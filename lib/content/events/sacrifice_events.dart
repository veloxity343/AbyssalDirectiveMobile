// Scenarios built around a choice that can cost crew lives directly (via
// `crewDelta`), as opposed to gambles (whose stakes are the 0-100 stats) or
// the Refugees chain (which grows the crew instead). Full mechanics doc in
// event_schema.dart.
//
// Ported 1:1 from the web prototype's src/content/events/sacrifice.js.

import '../effects.dart';
import 'event_schema.dart';

final List<GameEvent> sacrificeEvents = [
  GameEvent(
    id: "containment_breach",
    title: "Sealed In",
    text:
        "A pressure warning lights up for Sector 6 — three crew are still inside, and the breach is spreading faster than anyone can reach them.",
    weight: 1,
    requirements: [Requirement(cycleMin: 3)],
    choices: [
      Choice(
        label: "Seal the sector now",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The bulkhead closes on schedule. The pressure alarm stops. So does everything else in Sector 6.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(10))],
            crewDelta: const Delta.fixed(-3),
          ),
        ),
      ),
      Choice(
        label: "Try to get them out first",
        check: SkillCheck(stat: "hull", difficulty: 55),
        outcomes: Outcomes(
          success: Outcome(
            text: "They make it out with seconds to spare. The bulkhead seals behind them, empty.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(-8))],
          ),
          failure: Outcome(
            text: "The delay costs the whole sector, not just the three you were trying to save.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(-20))],
            crewDelta: const Delta.range(-10, -6),
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "rationing_crisis",
    title: "The Ration Count Doesn't Lie",
    text:
        "Supplies have dropped low enough that the numbers stop working no matter how you arrange them. Someone is going to have to eat less than they need.",
    weight: 1,
    requirements: [Requirement(stat: "supplies", max: 30), Requirement(cycleMin: 3)],
    choices: [
      Choice(
        label: "Enforce strict rationing across the board",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Nobody starves. Nobody's comfortable either.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-10))],
          ),
        ),
      ),
      Choice(
        label: "Cut the weakest crew loose from the count",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The math works out. You don't examine too closely who \"weakest\" turned out to mean.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(15)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-15)),
            ],
            crewDelta: const Delta.range(-8, -4),
          ),
        ),
      ),
    ],
  ),
];
