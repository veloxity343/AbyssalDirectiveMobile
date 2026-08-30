// Standalone site-discovery scenarios — `isSiteDiscovery: true`, not gated
// behind another event's flags. (Chain-terminal discoveries like
// theGreatBloom live in chain_events.dart instead, alongside the flags that
// gate them.) Full event/choice field schema, and how discoverSite/site
// stats work, lives in event_schema.dart.
//
// Ported 1:1 from the web prototype's src/content/events/siteDiscovery.js.

import '../effects.dart';
import 'event_schema.dart';

final List<GameEvent> siteDiscoveryEvents = [
  GameEvent(
    id: "fallback_ledge_survey",
    title: "A Shelf in the Silt",
    text:
        "Routine sonar mapping turns up a stable rock shelf half a kilometer out — nothing special, but flat, solid, and closer than anything else charted. It wouldn't be glamorous. It would hold.",
    weight: 2,
    once: true,
    isSiteDiscovery: true,
    requirements: [Requirement(cycleMin: 2)],
    choices: [
      Choice(
        label: "Send a survey team to confirm it",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You mark the coordinates. Not a home. A place to stop falling, if it comes to that.",
            effects: [StatEffect(stat: "supplies", delta: Delta.fixed(-8))],
            discoverSite: DiscoverSite(
              id: "fallback_ledge",
              name: "The Fallback Ledge",
              blurb: "A bare rock shelf, structurally sound and utterly unremarkable.",
            ),
          ),
        ),
      ),
      Choice(
        label: "Note the coordinates and move on",
        outcomes: Outcomes(
          defaultOutcome: Outcome(text: "Maybe something better is out there. You keep going.", effects: []),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "derelict_outpost_survey",
    title: "Static on an Old Channel",
    text:
        "A derelict corporate outpost is still broadcasting a weak beacon two kilometers down-slope — decommissioned, officially. Whatever's left of its hull might still be salvageable, or worth staking a claim to.",
    weight: 2,
    once: true,
    isSiteDiscovery: true,
    requirements: [Requirement(cycleMin: 5)],
    choices: [
      Choice(
        label: "Send a team to assess it",
        check: SkillCheck(stat: "hull", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "It's gutted, but the bones are sound. Someone decided it wasn't worth saving. You're not sure you agree.",
            effects: [StatEffect(stat: "supplies", delta: Delta.fixed(-5))],
            discoverSite: DiscoverSite(
              id: "derelict_outpost",
              name: "The Derelict Outpost",
              blurb: "A stripped corporate rig, salvageable but scarred — abandoned, not condemned.",
            ),
          ),
          failure: Outcome(
            text: "The approach goes wrong before the team even gets a look inside. Not everyone who went out comes back.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
              StatEffect(stat: "supplies", delta: Delta.fixed(-10)),
            ],
            crewDelta: Delta.range(-3, -1),
          ),
        ),
      ),
      Choice(
        label: "Leave it be — derelict for a reason",
        outcomes: Outcomes(
          defaultOutcome: Outcome(text: "Some wrecks aren't worth the dive.", effects: []),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "thermal_vent_shelf_survey",
    title: "Warmth From Below",
    text:
        "Sonar traces a thermal vent field close enough to reach — the water there runs warm enough to read on the hull sensors from here. Warm water means something's alive down there. Maybe something worth building on.",
    weight: 2,
    once: true,
    isSiteDiscovery: true,
    requirements: [Requirement(cycleMin: 1)],
    choices: [
      Choice(
        label: "Send a team to chart it",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "It's rougher than the readings suggested, but it's real, and it's close.",
            effects: [StatEffect(stat: "supplies", delta: Delta.fixed(-6))],
            discoverSite: DiscoverSite(
              id: "thermal_vent_shelf",
              name: "The Thermal Shelf",
              blurb: "A vent-warmed ridge, alive with things that don't need sunlight. Untested, but promising.",
            ),
          ),
        ),
      ),
      Choice(
        label: "Not worth the fuel",
        outcomes: Outcomes(
          defaultOutcome: Outcome(text: "You log the coordinates and keep them for later. Or never.", effects: []),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "coral_terrace_survey",
    title: "A Terrace of Something",
    text:
        "A mineral terrace rises from the silt like something built on purpose — layered in ridges too regular to be geology and too old to be anyone's construction. Whatever grew it, it's sturdy.",
    weight: 2,
    once: true,
    isSiteDiscovery: true,
    requirements: [Requirement(cycleMin: 4)],
    choices: [
      Choice(
        label: "Survey it for settlement viability",
        check: SkillCheck(stat: "hull", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "The terrace tests solid, layer after layer. Whatever built it built it to last.",
            effects: [StatEffect(stat: "supplies", delta: Delta.fixed(-5))],
            discoverSite: DiscoverSite(
              id: "coral_terrace",
              name: "The Coral Terrace",
              blurb: "A ridged mineral structure, uncomfortably regular in shape, and unreasonably sturdy.",
            ),
          ),
          failure: Outcome(
            text: "The survey team comes back early and won't say much about why.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-8)),
              StatEffect(stat: "supplies", delta: Delta.fixed(-8)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Log the anomaly and keep moving",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Some things are more useful uninvestigated.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-4))],
          ),
        ),
      ),
    ],
  ),
];
