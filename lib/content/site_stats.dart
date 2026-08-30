// Site stats describe a candidate settlement site's own geological/oceanic
// viability — deliberately NOT the same axes as the habitat's stats
// (stats.dart). A site doesn't have "sanity" or "corporate standing"; it has
// a seafloor and a chemistry and a pressure profile. Each one influences
// MULTIPLE habitat stats when settleAtSite (engine.dart, once written) blends
// them in — geology mostly decides whether the structure holds, but crew
// confidence in that structure is real too, so it gets a smaller pull on
// sanity as well. Weights for one site stat don't need to sum to 1; they're
// each an independent strength-of-pull on that target, aggregated
// per-target in engine.dart.
//
// Pressure Tolerance is the exception: it drives crew survival directly (a
// separate mechanic, not part of this blend — see settleAtSite), on top of
// the modest hull pull listed here.
//
// `danger`/`boon` are optional, and only fire once a site stat crosses
// [siteDangerThreshold]/[siteBoonThreshold] at settle time. Each is its own
// narrated incident in the ending: an extra nudge to whatever that site stat
// already `influences` (reusing those same weights, so a heavier influence
// takes a heavier hit), plus — only where physically plausible — a few extra
// casualties via `crewDelta`. Not every site stat's danger is a body count: a
// barren seafloor or a rough depth margin costs you materially, not
// necessarily lives.
//
// Ported 1:1 from the web prototype's src/content/siteStats.js.

import 'effects.dart';
import '../engine/game_state.dart';

class Influence {
  final String stat;
  final double weight;
  const Influence({required this.stat, required this.weight});
}

/// A settle-time incident triggered by a site stat crossing its danger or
/// boon threshold. `crewDelta` is only present where a casualty/survivor
/// count is physically plausible for that particular danger/boon (see the
/// per-entry comments below).
class SiteStatIncident {
  final String Function(SiteInstance site) text;
  final Delta? crewDelta;
  const SiteStatIncident({required this.text, this.crewDelta});
}

class SiteStat {
  final String id;
  final String label;
  final List<Influence> influences;
  final SiteStatIncident? danger;
  final SiteStatIncident? boon;
  const SiteStat({
    required this.id,
    required this.label,
    required this.influences,
    this.danger,
    this.boon,
  });
}

/// Below this, a site stat is a liability at settle time.
const int siteDangerThreshold = 30;

/// Above this, a site stat is an asset at settle time.
const int siteBoonThreshold = 75;

final List<SiteStat> siteStats = [
  SiteStat(
    id: "geology",
    label: "Geological Stability",
    influences: const [
      Influence(stat: "hull", weight: 0.7),
      Influence(stat: "sanity", weight: 0.3),
    ],
    danger: SiteStatIncident(
      text: (site) =>
          "The bedrock under ${site.name} never really settled. A support strut lets go inside the first week, and the crew doesn't have long to clear the section before it comes down.",
      crewDelta: const Delta.range(-12, -3),
    ),
    boon: SiteStatIncident(
      text: (site) =>
          "Whatever ${site.name} is built on hasn't shifted in longer than anyone down here can measure. The foundation isn't the thing you'll lose sleep over.",
    ),
  ),
  SiteStat(
    id: "thermal",
    label: "Thermal Viability",
    influences: const [
      Influence(stat: "oxygen", weight: 0.7),
      Influence(stat: "supplies", weight: 0.3),
    ],
    danger: SiteStatIncident(
      text: (site) =>
          "${site.name} runs hotter, or colder, than anything the scrubbers were rated for. Systems built to last years start failing in months.",
      crewDelta: const Delta.range(-6, -1),
    ),
    boon: SiteStatIncident(
      text: (site) =>
          "${site.name} sits in water so thermally stable it barely registers as an environment at all. One less thing down here trying to kill you.",
    ),
  ),
  SiteStat(
    id: "purity",
    label: "Water Purity",
    influences: const [
      Influence(stat: "sanity", weight: 0.7),
      Influence(stat: "oxygen", weight: 0.3),
    ],
    danger: SiteStatIncident(
      text: (site) =>
          "The water around ${site.name} tests wrong, and it doesn't test any better with time. Sickness moves fast through close quarters, and there's nowhere on the habitat that isn't close quarters.",
      crewDelta: const Delta.range(-9, -2),
    ),
    boon: SiteStatIncident(
      text: (site) =>
          "${site.name}'s water runs clean enough straight from the intake, no processing required. It's a small mercy, and the crew notices.",
    ),
  ),
  SiteStat(
    id: "biotic",
    label: "Biotic Yield",
    influences: const [
      Influence(stat: "supplies", weight: 0.7),
      Influence(stat: "sanity", weight: 0.3),
      Influence(stat: "oxygen", weight: 0.15),
    ],
    // No crewDelta: scarcity is a slow drain on supplies/sanity via the
    // influence-weighted nudge above, not a direct-casualty event.
    danger: SiteStatIncident(
      text: (site) =>
          "Not much grows around ${site.name}, and not much of what does is worth eating. The ration count starts running the wrong direction almost immediately.",
    ),
    boon: SiteStatIncident(
      text: (site) =>
          "${site.name} sits inside an ecosystem thick enough to actually live off of — real food, real oxygen, not just whatever the tanks provide.",
    ),
  ),
  SiteStat(
    id: "pressure",
    label: "Pressure Tolerance",
    influences: const [
      Influence(stat: "hull", weight: 0.4),
      Influence(stat: "sanity", weight: 0.2),
    ],
    // No crewDelta here: pressure already drives crew survival directly via
    // the dedicated transition-casualty formula in settleAtSite — a second,
    // separate crewDelta here would double-count the same danger.
    danger: SiteStatIncident(
      text: (site) =>
          "The depth at ${site.name} strains the hull in ways no amount of reinforcement fully accounts for. Everyone feels it, even the ones who won't say so.",
    ),
    boon: SiteStatIncident(
      text: (site) =>
          "The pressure gradient around ${site.name} is almost forgiving, as these things go — one axis the crew doesn't have to fight.",
    ),
  ),
];
