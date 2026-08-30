// One-off scenarios: no site-discovery tag, no gamble, not part of a
// multi-step chain, and not built around a crew-sacrifice choice. Most are
// repeatable, drawn purely by weight — the day-to-day texture of the run.
// Full event/choice field schema lives in event_schema.dart.
//
// Ported 1:1 from the web prototype's src/content/events/standalone.js.

import '../effects.dart';
import 'event_schema.dart';

final List<GameEvent> standaloneEvents = [
  GameEvent(
    id: "hull_groan",
    title: "A Groan in the Dark",
    text:
        "A structural groan rolls through Sector 4 like a held breath finally let out. The plating flexes, almost imperceptibly, under the black water's weight.",
    weight: 3,
    choices: [
      Choice(
        label: "Divert supplies to reinforce the plating",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The reinforcement holds fast. It cost you materials you needed elsewhere.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(-15)),
              StatEffect(stat: "hull", delta: Delta.fixed(12)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Log it and hope it holds",
        check: SkillCheck(stat: "hull", difficulty: 55),
        outcomes: Outcomes(
          success: Outcome(
            text: "It holds. This time.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(-3))],
          ),
          failure: Outcome(
            text: "It doesn't. The groan becomes a shriek of tearing metal before your team seals it off.",
            effects: [StatEffect(stat: "hull", delta: Delta.range(-20, -10))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "scrubber_fault",
    title: "Scrubber Fault",
    text: "Sector 3's oxygen scrubber throws an error code nobody on staff recognizes.",
    weight: 3,
    choices: [
      Choice(
        label: "Pull the engineer off sleep rotation to fix it",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "She gets it running again, bleary-eyed and furious about it.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(-10)),
              StatEffect(stat: "oxygen", delta: Delta.fixed(15)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-5)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Ration oxygen flow until it clears on its own",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The air thins. Crew tempers thin with it.",
            effects: [
              StatEffect(stat: "oxygen", delta: Delta.fixed(-5)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "crew_dispute",
    title: "Mess Hall Shouting",
    text: "Two crew members are shouting in the mess hall again, over rationing decisions you made last week.",
    weight: 2,
    choices: [
      Choice(
        label: "Side with the senior officer",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Order is restored, but you notice who stops meeting your eyes afterward.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(8))],
          ),
        ),
      ),
      Choice(
        label: "Mediate and hear both sides out",
        check: SkillCheck(stat: "sanity", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "You talk them down. For an evening, the habitat feels like a crew instead of a crowd.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(15))],
          ),
          failure: Outcome(
            text: "It goes nowhere. Someone throws a tray. Cleanup eats into tomorrow's supplies.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
              StatEffect(stat: "supplies", delta: Delta.fixed(-5)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "corporate_audit",
    title: "Quarterly Review",
    text:
        "Corporate wants a full status report before the quarterly review. What you send up the wire will shape how they see you.",
    weight: 2,
    requirements: [Requirement(cycleMin: 2)],
    choices: [
      Choice(
        label: "Send the honest numbers",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The truth doesn't play well in a boardroom. Your standing takes the hit it usually does.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-8))],
          ),
        ),
      ),
      Choice(
        label: "Pad the report to look stable",
        check: SkillCheck(stat: "favour", difficulty: 45),
        outcomes: Outcomes(
          success: Outcome(
            text: "They buy it. Confidence in your command climbs.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(12))],
          ),
          failure: Outcome(
            text: "An auditor catches the discrepancy. Your name goes into a file you'll hear about later.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-15))],
            setFlags: {"flaggedDishonest": true},
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "supply_drone_delay",
    title: "Resupply Slips Again",
    text: "The resupply drone's ETA slips again. Corporate blames weather on the surface; you suspect budget.",
    weight: 3,
    choices: [
      Choice(
        label: "Cut rations to stretch what's left",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Bellies stay empty a little longer than they should. Nobody says anything at dinner.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(5)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Request an emergency drop",
        check: SkillCheck(stat: "favour", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "It surfaces two days later, waterlogged crates and all. Corporate notes the favour spent.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(20)),
              StatEffect(stat: "favour", delta: Delta.fixed(-5)),
            ],
          ),
          failure: Outcome(
            text: "Denied. \"Non-critical,\" the memo says.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-15))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "bioluminescent_window",
    title: "Something at the Glass",
    text:
        "Something enormous and glowing drifts past the observation window, indifferent to the tons of pressure between you and it. For a moment, half the crew forgets to be afraid.",
    weight: 1,
    once: true,
    requirements: [Requirement(cycleMin: 4)],
    choices: [
      Choice(
        label: "Let the crew gather and watch",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Work stops for twenty minutes. Nobody complains about the lost time.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(15)),
              StatEffect(stat: "supplies", delta: Delta.fixed(-3)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Order everyone back to their stations",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Discipline holds. Corporate would approve, if they ever knew this happened.",
            effects: [
              StatEffect(stat: "favour", delta: Delta.fixed(5)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-5)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "leak_sector3",
    title: "Hairline Leak",
    text: "A hairline leak opens in Sector 3's outer seam. Water finds it before your sensors do.",
    weight: 2,
    requirements: [Requirement(stat: "hull", max: 60)],
    choices: [
      Choice(
        label: "Seal the sector and abandon what's inside",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You lose whatever was stored there, but the rest of the habitat stays dry.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(-15)),
              StatEffect(stat: "hull", delta: Delta.fixed(5)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Send a team to patch it live",
        check: SkillCheck(stat: "hull", difficulty: 55),
        outcomes: Outcomes(
          success: Outcome(
            text: "They get the patch welded before it widens. Barely.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(10))],
          ),
          failure: Outcome(
            text: "The seam splits wider mid-repair. Two crew make it out; the panic doesn't stay behind.",
            effects: [
              StatEffect(stat: "hull", delta: Delta.fixed(-15)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "rescue_request",
    title: "A Standing Worth Spending",
    text:
        "You could formally request evacuation. Corporate rarely approves early extraction, but standing this good doesn't come around twice.",
    weight: 1,
    once: true,
    requirements: [Requirement(stat: "favour", min: 60), Requirement(cycleMin: 8)],
    choices: [
      Choice(
        label: "File the request",
        check: SkillCheck(stat: "favour", difficulty: 55),
        outcomes: Outcomes(
          success: Outcome(
            text: "Approval comes through, stamped and cold. A retrieval sub is scheduled.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-10))],
            setFlags: {"rescueApproved": true},
          ),
          failure: Outcome(
            text: "Denied, without explanation.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-20))],
          ),
        ),
      ),
      Choice(
        label: "Hold off and keep working",
        outcomes: Outcomes(
          defaultOutcome: Outcome(text: "Not yet. There will be another chance, probably.", effects: []),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "flooded_corridor",
    title: "Water Where It Shouldn't Be",
    text:
        "Sector 2's connecting corridor is ankle-deep and rising. The bilge pumps are keeping pace, for now, but \"for now\" has a shelf life.",
    weight: 2,
    choices: [
      Choice(
        label: "Reroute power from other systems to the pumps",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The pumps win, this time. The scrubbers grumble about it for a day.",
            effects: [
              StatEffect(stat: "hull", delta: Delta.fixed(8)),
              StatEffect(stat: "oxygen", delta: Delta.fixed(-6)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Have the crew bail it by hand",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "It works, eventually, in the way that exhausting a problem counts as solving it.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-8)),
              StatEffect(stat: "supplies", delta: Delta.fixed(-4)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "silent_crewmate",
    title: "Someone Stopped Talking",
    text:
        "One of the technicians hasn't spoken in two days. Still working, still eating, just quiet, in a way that unsettles the others more than shouting would.",
    weight: 2,
    choices: [
      Choice(
        label: "Give them space",
        check: SkillCheck(stat: "sanity", difficulty: 45),
        outcomes: Outcomes(
          success: Outcome(
            text: "On the third day, she talks again, like nothing happened. Nobody asks about it.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(10))],
          ),
          failure: Outcome(
            text: "The silence spreads. By the end of the week, two more crew have gone quiet too.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-12))],
          ),
        ),
      ),
      Choice(
        label: "Pull them off duty for a psych evaluation",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The evaluation finds nothing conclusive. The crew notices the empty station anyway.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(5)),
              StatEffect(stat: "supplies", delta: Delta.fixed(-5)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "power_rationing",
    title: "The Reactor Dips",
    text:
        "Output from the reactor core dips below spec — not enough to panic over, but enough that something has to go without.",
    weight: 2,
    choices: [
      Choice(
        label: "Ration power to the labs",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate's research quotas slip. You'll hear about it eventually.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-6))],
          ),
        ),
      ),
      Choice(
        label: "Ration power to crew quarters",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The labs stay productive. The crew's patience does not.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-8)),
              StatEffect(stat: "favour", delta: Delta.fixed(3)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "corporate_specialist",
    title: "A Specialist, They Call Her",
    text:
        "Corporate wants to attach an outside specialist to your crew roster — officially for \"efficiency auditing.\" Nobody down here believes that's the whole story.",
    weight: 2,
    requirements: [Requirement(cycleMin: 3)],
    choices: [
      Choice(
        label: "Accept her aboard",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "She keeps to herself and writes a great deal. The crew keeps its distance right back.",
            effects: [
              StatEffect(stat: "favour", delta: Delta.fixed(12)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Decline, citing capacity",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate notes the refusal without comment, which is somehow worse than a complaint.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-10))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "storm_surge",
    title: "The Trench Exhales",
    text:
        "A deep current surge rattles the habitat's moorings hard enough to knock loose gear off shelving. It passes in under a minute. It feels much longer.",
    weight: 2,
    choices: [
      Choice(
        label: "Brace every sector before it peaks",
        check: SkillCheck(stat: "hull", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "The bracing holds. The habitat groans but doesn't give.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(5))],
          ),
          failure: Outcome(
            text: "Something in Sector 4 wasn't braced well enough. It shows.",
            effects: [
              StatEffect(stat: "hull", delta: Delta.fixed(-12)),
              StatEffect(stat: "supplies", delta: Delta.fixed(-5)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Ride it out and assess after",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Whatever breaks, breaks. You count the damage once it's quiet again.",
            effects: [
              StatEffect(stat: "hull", delta: Delta.range(-10, -2)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-5)),
            ],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "black_market_trade",
    title: "A Vessel Off the Books",
    text:
        "An unmarked supply vessel idles just outside sensor range, hailing on a frequency corporate doesn't monitor. They're offering to trade — no paperwork, no questions.",
    weight: 1,
    requirements: [Requirement(cycleMin: 3)],
    choices: [
      Choice(
        label: "Trade quietly",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The exchange takes eleven minutes. Nobody logs it. The supplies are real enough.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(18)),
              StatEffect(stat: "favour", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Refuse contact",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You let the hail go unanswered. The crew seems relieved you did.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(3))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "shared_nightmares",
    title: "The Same Dream, Twice",
    text:
        "Three crew members report the same dream, independently: a light in the water, and something behind it that isn't looking for them so much as waiting.",
    weight: 1,
    requirements: [Requirement(cycleMin: 4)],
    choices: [
      Choice(
        label: "Hold a session to talk it through",
        check: SkillCheck(stat: "sanity", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "Saying it out loud takes most of its power away. Most.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(12))],
          ),
          failure: Outcome(
            text: "Comparing notes only confirms how identical the dream was. That's worse.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-8))],
          ),
        ),
      ),
      Choice(
        label: "Log it and say nothing",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You don't mention it. The crew talks about it anyway, quietly, in the mess hall.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-6))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "equipment_failure",
    title: "Something Seizes",
    text:
        "A critical valve seizes in Sector 1 with no warning and no obvious cause. The manual override works, for now, on borrowed time.",
    weight: 2,
    choices: [
      Choice(
        label: "Cannibalize spare parts from elsewhere",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The valve holds. Something else down here is now short a part it needed.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(-10)),
              StatEffect(stat: "hull", delta: Delta.fixed(8)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Jury-rig a fix with what's on hand",
        check: SkillCheck(stat: "hull", difficulty: 45),
        outcomes: Outcomes(
          success: Outcome(
            text: "It's ugly, but it holds, and it cost you nothing you didn't already have.",
            effects: [StatEffect(stat: "hull", delta: Delta.fixed(5))],
          ),
          failure: Outcome(
            text: "The fix fails within the hour. The second attempt costs more than the first would have.",
            effects: [
              StatEffect(stat: "hull", delta: Delta.fixed(-8)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-5)),
            ],
          ),
        ),
      ),
    ],
  ),
];
