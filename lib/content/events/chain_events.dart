// Multi-step narrative chains — later steps are gated behind flags set by
// earlier ones (via `Requirement(flag: ...)`). Four chains live here:
//
//   Anomaly/Bloom (3 steps): sonarPing -> anomalyBiostudy -> theGreatBloom
//     A single path to a high-quality site discovery.
//   Stowaway (2-4 steps, branches at step 2): stowawaySigns ->
//     stowawayConfronted -> stowawayResolutionAlly OR
//     stowawayResolutionExposed. A single playthrough only ever resolves
//     one branch.
//   Inspector (2-3 steps, branches at step 1): inspectorIncoming ->
//     inspectorDepartureImpressed OR inspectorDepartureAlarmed.
//   Refugees (3 steps): distressSignalReceived -> refugeesArrive ->
//     colonyFlourishes. The "proliferation" chain — following it through to
//     colonyFlourishes is the only way GameState.crewCount grows past its
//     start.
//
// Full event/choice field schema lives in event_schema.dart. Kept in one
// file (rather than one per chain) since "chain" is the shared mechanical
// trait here — split further if any one chain grows large enough to want
// its own file.
//
// Ported 1:1 from the web prototype's src/content/events/chains.js.

import '../effects.dart';
import 'event_schema.dart';

final List<GameEvent> chainEvents = [
  // --- Anomaly / Bloom ---
  GameEvent(
    id: "sonar_ping",
    title: "A Ping With No Chart",
    text: "The passive sonar array picks up a rhythmic ping from beyond the trench wall. It isn't on any chart, and it isn't natural.",
    weight: 2,
    once: true,
    requirements: [Requirement(cycleMin: 3)],
    choices: [
      Choice(
        label: "Send a drone to investigate",
        check: SkillCheck(stat: "sanity", difficulty: 60),
        outcomes: Outcomes(
          success: Outcome(
            text: "The drone's footage is worth more to corporate than anything else you've sent up this quarter.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(10))],
            setFlags: {"foundAnomaly": true},
          ),
          failure: Outcome(
            text: "The feed cuts to static. The drone doesn't answer its recall signal, and neither does whatever answered it first.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(-10)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Note it in the log and move on",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You tell yourself it's nothing. The crew doesn't quite believe you, and neither do you.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-5))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "anomaly_biostudy",
    title: "Study the Glow",
    text: "The signal from beyond the trench wall traces back to something growing on the rock face — a colony of bioluminescent tissue, pulsing in a rhythm too even to be coincidence. It's the same light your crew watched drift past the window, weeks ago. It hasn't stopped growing since.",
    weight: 2,
    once: true,
    requirements: [Requirement(flag: "foundAnomaly"), Requirement(cycleMin: 6)],
    choices: [
      Choice(
        label: "Attempt to cultivate it as a food and oxygen source",
        check: SkillCheck(stat: "sanity", difficulty: 55),
        outcomes: Outcomes(
          success: Outcome(
            text: "It takes to the nutrient beds faster than anything corporate ever shipped down. The air already tastes different.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(15)),
              StatEffect(stat: "oxygen", delta: Delta.fixed(10)),
            ],
            setFlags: {"cultivationSuccess": true},
          ),
          failure: Outcome(
            text: "It reacts to handling like it's defending itself. Whatever it did to the containment team, they don't want to talk about it.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(-10)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Catalog it and report the coordinates for a bounty",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate is delighted. A discovery is easier to sell than a habitat that's falling apart.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(15))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "the_great_bloom",
    title: "The Bloom",
    text: "The cultivated growth hasn't stayed in its containment bed. It's threading itself through the ventilation, the water reclaimers, the walls themselves — quietly rewriting what this habitat depends on to survive.",
    weight: 2,
    once: true,
    isSiteDiscovery: true,
    requirements: [Requirement(flag: "cultivationSuccess"), Requirement(cycleMin: 10)],
    choices: [
      Choice(
        label: "Let it integrate fully into life support",
        check: SkillCheck(stat: "hull", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "The habitat breathes on its own now, in every sense. Whatever this place becomes, it won't need the surface's permission to keep breathing.",
            effects: [
              StatEffect(stat: "oxygen", delta: Delta.fixed(20)),
              StatEffect(stat: "supplies", delta: Delta.fixed(20)),
              StatEffect(stat: "sanity", delta: Delta.fixed(15)),
            ],
            discoverSite: DiscoverSite(
              id: "bloom_hollow",
              name: "The Bloom Hollow",
              blurb:
                  "A self-sustaining reef grown from the cultivated bloom, glowing faint blue in every vent and duct. It doesn't need corporate's signature to keep breathing.",
            ),
          ),
          failure: Outcome(
            text: "Something in the integration goes wrong, fast. The reclaimers choke on tissue that was never meant to be filtered.",
            effects: [
              StatEffect(stat: "hull", delta: Delta.fixed(-15)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-15)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Keep it contained, just in case",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You seal the bed and post a guard on it. Safer. Slower. Still yours to decide, later.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(5))],
          ),
        ),
      ),
    ],
  ),

  // --- Stowaway ---
  GameEvent(
    id: "stowaway_signs",
    title: "Rations Gone Missing",
    text: "Supply counts don't add up. Someone — or something — has been drawing rations that were never logged. The manifest says everyone's accounted for.",
    weight: 2,
    once: true,
    requirements: [Requirement(cycleMin: 3)],
    choices: [
      Choice(
        label: "Report the discrepancy to corporate immediately",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate appreciates the transparency more than you expected them to.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(6))],
            setFlags: {"reportedStowaway": true},
          ),
        ),
      ),
      Choice(
        label: "Investigate quietly before saying anything",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You keep it off the log for now. The not-knowing gnaws at you more than you'd like.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(-3))],
            setFlags: {"investigatingStowaway": true},
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "stowaway_confronted",
    title: "Whoever It Is, It's Watching",
    text: "Motion sensors in the disused Sector 5 corridor trip twice in one night. Whoever's been hiding down here has been closer than anyone realized.",
    weight: 2,
    once: true,
    requirements: [Requirement(flag: "investigatingStowaway"), Requirement(cycleMin: 5)],
    choices: [
      Choice(
        label: "Corner them and find out who they are",
        check: SkillCheck(stat: "sanity", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "She's been hiding from a debt collector with corporate reach, not from you. She asks, quietly, if she can stay.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(8))],
            setFlags: {"stowawayAlly": true},
          ),
          failure: Outcome(
            text: "She bolts into the flooded sections before you get a name. Corporate hears about the breach regardless.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-10)),
              StatEffect(stat: "favour", delta: Delta.fixed(-8)),
            ],
            setFlags: {"stowawayExposed": true},
          ),
        ),
      ),
      Choice(
        label: "Report the sighting up the chain instead",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate says they'll \"handle it.\" You don't like how quickly they say it.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(8))],
            setFlags: {"stowawayExposed": true},
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "stowaway_resolution_ally",
    title: "An Extra Set of Hands",
    text: "She's been living in the disused ballast tanks for two months, and she knows this habitat's blind spots better than the crew does. She offers to make herself useful, if you'll let her stay.",
    weight: 1,
    once: true,
    isSiteDiscovery: true,
    requirements: [Requirement(flag: "stowawayAlly"), Requirement(cycleMin: 8)],
    choices: [
      Choice(
        label: "Let her guide a survey of the tanks she's mapped",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "She's already half-converted them into somewhere livable, with nothing but time and nowhere else to go.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(10))],
            discoverSite: DiscoverSite(
              id: "ballast_hollow",
              name: "The Ballast Hollow",
              blurb:
                  "A maze of decommissioned tanks, already half-converted into something livable by someone with nowhere else to go.",
            ),
          ),
        ),
      ),
      Choice(
        label: "Keep her hidden, and keep her out of it",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "She stays below the manifest. The crew that knows about her seems steadier for it.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(5))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "stowaway_resolution_exposed",
    title: "Corporate Sends a Retrieval Team",
    text: "A retrieval team arrives inside forty-eight hours — corporate doesn't move that fast for anything else. Whoever was hiding down here is gone before you get a name.",
    weight: 1,
    once: true,
    requirements: [Requirement(flag: "stowawayExposed"), Requirement(cycleMin: 8)],
    choices: [
      Choice(
        label: "Let it go quietly",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate is pleased with the cooperation. The crew is quiet in a different way than usual.",
            effects: [
              StatEffect(stat: "favour", delta: Delta.fixed(15)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-12)),
            ],
          ),
        ),
      ),
      Choice(
        label: "Ask questions corporate won't answer",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You don't get answers. The crew notices you asked anyway.",
            effects: [
              StatEffect(stat: "favour", delta: Delta.fixed(-10)),
              StatEffect(stat: "sanity", delta: Delta.fixed(6)),
            ],
          ),
        ),
      ),
    ],
  ),

  // --- Inspector ---
  GameEvent(
    id: "inspector_incoming",
    title: "A Live Inspection, For Once",
    text: "Corporate isn't sending a form this time. An actual inspector is descending to see this habitat in person — the first one anyone's sent below the thermocline in years.",
    weight: 2,
    once: true,
    requirements: [Requirement(cycleMin: 6)],
    choices: [
      Choice(
        label: "Prepare the habitat to impress",
        check: SkillCheck(stat: "favour", difficulty: 50),
        outcomes: Outcomes(
          success: Outcome(
            text: "Whatever she came looking for, she doesn't find it. The report will say so.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(15))],
            setFlags: {"inspectorImpressed": true},
          ),
          failure: Outcome(
            text: "Nothing you staged was convincing. She writes the whole visit down, in detail.",
            effects: [
              StatEffect(stat: "favour", delta: Delta.fixed(-10)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-8)),
            ],
            setFlags: {"inspectorAlarmed": true},
          ),
        ),
      ),
      Choice(
        label: "Show them exactly how things are",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "No staging, no script. The crew stands a little taller watching you do it.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(10))],
            setFlags: {"inspectorAlarmed": true},
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "inspector_departure_impressed",
    title: "A Rare Endorsement",
    text: "The inspector leaves impressed — genuinely, as far as you can tell, which is rarer than the paperwork ever lets on. Before the sub departs, she mentions an off-record site corporate surveyed years ago and shelved over budget. She leaves you the coordinates.",
    weight: 1,
    once: true,
    isSiteDiscovery: true,
    requirements: [Requirement(flag: "inspectorImpressed"), Requirement(cycleMin: 8)],
    choices: [
      Choice(
        label: "Take the coordinates seriously",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Whatever killed the old project, the survey data says it wasn't the ground beneath it.",
            discoverSite: DiscoverSite(
              id: "shelved_survey_site",
              name: "The Shelved Site",
              blurb: "A pre-surveyed foundation corporate abandoned over a budget line, not a structural one.",
            ),
          ),
        ),
      ),
      Choice(
        label: "File them away and worry about it later",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You thank her for the tip and put it out of mind, for now.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(5))],
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "inspector_departure_alarmed",
    title: "A Report That Won't Flatter Anyone",
    text: "The inspector leaves rattled, muttering about what she'll have to write up. Whatever happens to her report happens well above your pay grade now.",
    weight: 1,
    once: true,
    requirements: [Requirement(flag: "inspectorAlarmed"), Requirement(cycleMin: 8)],
    choices: [
      Choice(
        label: "Brace for fallout",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The fallout arrives on schedule, in the form of a much shorter budget.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-15))],
          ),
        ),
      ),
      Choice(
        label: "Get ahead of it — send your own account first",
        check: SkillCheck(stat: "favour", difficulty: 55),
        outcomes: Outcomes(
          success: Outcome(
            text: "Your version reaches the right desk before hers does. It helps, some.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(5))],
          ),
          failure: Outcome(
            text: "It reads as exactly what it is: damage control. It does more harm than the silence would have.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-20))],
          ),
        ),
      ),
    ],
  ),

  // --- Refugees (proliferation) ---
  GameEvent(
    id: "distress_signal_received",
    title: "A Signal That Isn't Yours",
    text: "A distress beacon crackles through on an old frequency — another habitat, or what's left of one, still broadcasting on batteries that shouldn't last much longer.",
    weight: 2,
    once: true,
    requirements: [Requirement(cycleMin: 5)],
    choices: [
      Choice(
        label: "Investigate and offer aid",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "You change course toward the signal. Corporate hasn't authorized this, and you don't ask.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(-5))],
            setFlags: {"investigatingRefugees": true},
          ),
        ),
      ),
      Choice(
        label: "Report it and let corporate handle it",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate thanks you for the report. What \"handling it\" means, they don't say, and you don't ask.",
            effects: [StatEffect(stat: "favour", delta: Delta.fixed(8))],
            setFlags: {"reportedRefugees": true},
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "refugees_arrive",
    title: "Knocking From the Outside",
    text: "A handful of survivors reach your outer airlock — cold, waterlogged, and asking for something you were never budgeted to give: shelter.",
    weight: 2,
    once: true,
    requirements: [Requirement(flag: "investigatingRefugees"), Requirement(cycleMin: 7)],
    choices: [
      Choice(
        label: "Take them in",
        check: SkillCheck(stat: "supplies", difficulty: 45),
        outcomes: Outcomes(
          success: Outcome(
            text: "There's just enough to go around, and then some. The habitat feels less empty than it has in weeks.",
            effects: [StatEffect(stat: "sanity", delta: Delta.fixed(10))],
            crewDelta: const Delta.range(15, 28),
            setFlags: {"refugeesWelcomed": true},
          ),
          failure: Outcome(
            text: "You take them in anyway. The math doesn't forgive the decision, but nobody in this room would take it back.",
            effects: [
              StatEffect(stat: "supplies", delta: Delta.fixed(-20)),
              StatEffect(stat: "sanity", delta: Delta.fixed(5)),
            ],
            crewDelta: const Delta.range(15, 28),
            setFlags: {"refugeesWelcomed": true},
          ),
        ),
      ),
      Choice(
        label: "Turn them away",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "The airlock stays sealed. Nobody on this side of it feels good about the decision, including you.",
            effects: [
              StatEffect(stat: "sanity", delta: Delta.fixed(-15)),
              StatEffect(stat: "favour", delta: Delta.fixed(5)),
            ],
            setFlags: {"refugeesTurnedAway": true},
          ),
        ),
      ),
    ],
  ),
  GameEvent(
    id: "colony_flourishes",
    title: "More Hands Than the Manifest Accounts For",
    text: "What started as a rescue has become something else — new faces on every shift, more voices in the mess hall than the ration algorithms were ever designed around. The habitat isn't just surviving anymore. It's growing.",
    weight: 1,
    once: true,
    requirements: [Requirement(flag: "refugeesWelcomed"), Requirement(cycleMin: 15)],
    choices: [
      Choice(
        label: "Formalize it — integrate them fully into the crew roster",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Corporate will notice the numbers eventually. For now, this is simply what the crew looks like.",
            effects: [
              StatEffect(stat: "favour", delta: Delta.fixed(-10)),
              StatEffect(stat: "sanity", delta: Delta.fixed(15)),
            ],
            crewDelta: const Delta.range(20, 40),
          ),
        ),
      ),
      Choice(
        label: "Keep the arrangement informal, off the official count",
        outcomes: Outcomes(
          defaultOutcome: Outcome(
            text: "Easier to explain to corporate. Harder to explain to the people who live here now, why they still don't officially exist.",
            effects: [
              StatEffect(stat: "favour", delta: Delta.fixed(5)),
              StatEffect(stat: "sanity", delta: Delta.fixed(-5)),
            ],
            crewDelta: const Delta.range(10, 20),
          ),
        ),
      ),
    ],
  ),
];
