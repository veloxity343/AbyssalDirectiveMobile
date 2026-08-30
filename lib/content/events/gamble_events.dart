// High-risk choices tagged `gamble: true` — odds stay fixed regardless of
// cycle (authored `check.difficulty` high, ~78-82, so success is a genuine
// long shot), but the engine scales the resulting effects up the deeper into
// the run the choice is resolved (once engine.dart exists — see
// Delta.scaled). Kept repeatable (no `once`) so the escalation is visible
// within a single playthrough. Full mechanics doc in event_schema.dart.
//
// Ported 1:1 from the web prototype's src/content/events/gambles.js.

import '../effects.dart';
import 'event_schema.dart';

final List<GameEvent> gambleEvents = [
  GameEvent(
    id: "reactor_overdrive",
    title: "Past the Red Line",
    text:
        "The reactor core can be pushed well past its rated ceiling — corporate's own manual says so, in the fine print nobody's meant to read twice. It would buy a great deal, if the containment holds.",
    weight: 1,
    choices: [
      Choice(
        label: "Leave it running within spec",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You leave the red line alone. Nothing changes, which is its own kind of relief.",
            effects: [],
          ),
        ),
      ),
      Choice(
        label: "Push it past the ceiling",
        check: SkillCheck(stat: "hull", difficulty: 80),
        gamble: true,
        outcomes: Outcomes(
          success: Outcome(
            text: "The containment holds, barely, and the output surges exactly as the fine print promised.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(18)),
              StatEffect(stat: "favour", delta: Delta.fixed(12)),
            ],
          ),
          failure: Outcome(
            text: "Something in the containment doesn't hold. The damage is immediate, and it is not subtle.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(-22))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "black_current_dive",
    title: "Something Worth the Risk",
    text:
        "Sonar keeps snagging on something heavy in the black current past the safe descent line — cargo, maybe, or worse, but heavy enough to be worth retrieving if a diver can reach it and back.",
    weight: 1,
    requirements: [Requirement(cycleMin: 2)],
    choices: [
      Choice(
        label: "Call the dive off",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Whatever it is stays down there. The crew doesn't stop wondering about it.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-3))],
          ),
        ),
      ),
      Choice(
        label: "Send a diver past the line",
        check: SkillCheck(stat: "sanity", difficulty: 80),
        gamble: true,
        outcomes: Outcomes(
          success: Outcome(
            text: "She surfaces with more than anyone expected, and a story she won't finish telling.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(15)),
              StatEffect(stat: "favour", delta: Delta.fixed(15)),
            ],
          ),
          failure: Outcome(
            text: "She surfaces without it, and without most of her composure. Whatever she saw down there, she isn't saying.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-20)),
              StatEffect(stat: "hull", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "overclock_life_support",
    title: "Redlining the Reclaimers",
    text:
        "Every life support system down here has a safety margin built in for exactly this: the option to run them past spec, all at once, and catch up on every deficit in a single night. It's not meant to be done twice.",
    weight: 1,
    requirements: [Requirement(cycleMin: 3)],
    choices: [
      Choice(
        label: "Run them within their margins",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You let the deficits sit. They'll still be there tomorrow, unchanged.",
            effects: [],
          ),
        ),
      ),
      Choice(
        label: "Redline every system at once",
        check: SkillCheck(stat: "supplies", difficulty: 80),
        gamble: true,
        outcomes: Outcomes(
          success: Outcome(
            text: "For one night, the habitat runs like it did on the day it was commissioned.",
            effects: [
              StatEffect(stat: "oxygen", delta: Delta.fixed(15)),
              StatEffect(stat: "sanity", delta: Delta.fixed(10)),
              StatEffect(stat: "supplies", delta: Delta.fixed(10)),
            ],
          ),
          failure: Outcome(
            text: "Something blows out under the load, loudly, and takes a chunk of the hull's margin with it.",
            effects: [
              StatEffect(stat: "oxygen", delta: Delta.fixed(-20)),
              StatEffect(stat: "hull", delta: Delta.fixed(-15)),
            ],
          ),
        ),
      ),
    ],
  ),
];
