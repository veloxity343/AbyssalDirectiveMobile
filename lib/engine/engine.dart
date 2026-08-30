// Game logic — ported 1:1 from the web prototype's src/engine.js, with one
// deliberate change: every function that needs randomness takes an explicit
// `Random rng` parameter instead of reaching for a global source, so this
// whole module is unit-testable with a seeded `Random(seed)` (see
// rng.dart's header for why). The GameState shape itself lives in
// game_state.dart, not here, since content/*.dart needs to reference it too.

import 'dart:math';

import '../content/stats.dart' as stats_content;
import '../content/site_stats.dart' as site_stats_content;
import '../content/anomalies.dart' as anomalies_content;
import '../content/events/events.dart' as events_content;
import '../content/events/event_schema.dart';
import '../content/endings.dart' as endings_content;
import '../content/settlement.dart' as settlement_content;
import '../content/effects.dart';
import 'game_state.dart';
import 'rng.dart';

int generateDirectiveNumber(Random rng) => rng.nextInt(999) + 1;

/// 1, 2, or 3 — how many plain scenarios can pass before a site-related one
/// (a new discovery opportunity, or an already-found site resurfacing) is
/// forced.
int randomSiteInterval(Random rng) => rng.nextInt(3) + 1;

GameState createInitialState(Random rng, {int? directiveNumber}) {
  final statsMap = <String, int>{for (final s in stats_content.stats) s.id: s.start};
  return GameState(
    directiveNumber: directiveNumber ?? generateDirectiveNumber(rng),
    cycle: 1,
    stats: statsMap,
    crewCount: stats_content.startingCrew,
    drones: stats_content.startingDrones,
    flags: {},
    sites: [],
    siteCountdown: randomSiteInterval(rng),
    usedEventIds: {},
    log: [],
  );
}

int _clamp(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);

/// Crew has no fixed ceiling (proliferation can grow it past its start), just
/// a floor and a generous soft cap so a content bug can't send it unbounded.
int _clampCrew(int v) => v < 0 ? 0 : (v > 500 ? 500 : v);

/// A requirement gates whether an event/choice is eligible.
bool requirementsMet(List<Requirement>? reqs, GameState state) {
  if (reqs == null) return true;
  for (final r in reqs) {
    if (r.stat != null) {
      final v = state.stats[r.stat] ?? 0;
      if (r.min != null && v < r.min!) return false;
      if (r.max != null && v > r.max!) return false;
    }
    if (r.flag != null) {
      final want = r.flagIs ?? true;
      if ((state.flags[r.flag] ?? false) != want) return false;
    }
    if (r.cycleMin != null && state.cycle < r.cycleMin!) return false;
    if (r.cycleMax != null && state.cycle > r.cycleMax!) return false;
  }
  return true;
}

List<GameEvent> getEligibleEvents(GameState state) {
  return events_content.events.where((e) {
    if (e.once && state.usedEventIds.contains(e.id)) return false;
    return requirementsMet(e.requirements, state);
  }).toList();
}

T? _weightedPick<T>(List<T> pool, int Function(T) weightOf, Random rng) {
  if (pool.isEmpty) return null;
  final totalWeight = pool.fold<int>(0, (sum, e) => sum + weightOf(e));
  var roll = rng.nextDouble() * totalWeight;
  for (final e in pool) {
    roll -= weightOf(e);
    if (roll <= 0) return e;
  }
  return pool.last;
}

/// Weighted random draw across all eligible events.
GameEvent? drawEvent(GameState state, Random rng) =>
    _weightedPick(getEligibleEvents(state), (e) => e.weight, rng);

/// Pulls only from events explicitly tagged `isSiteDiscovery: true` — used to
/// guarantee a site-related scenario shows up within a bounded number of
/// turns rather than leaving it purely to weighted luck across the whole
/// event pool.
GameEvent? drawSiteDiscoveryEvent(GameState state, Random rng) => _weightedPick(
      getEligibleEvents(state).where((e) => e.isSiteDiscovery).toList(),
      (e) => e.weight,
      rng,
    );

void applyEffects(GameState state, List<StatEffect>? effects, Random rng) {
  if (effects == null) return;
  for (final eff in effects) {
    state.stats[eff.stat] = _clamp((state.stats[eff.stat] ?? 0) + eff.delta.roll(rng));
  }
}

/// crewDelta on an outcome is a raw headcount change, separate from
/// `effects` since crew isn't a 0-100 gauge.
void applyCrewDelta(GameState state, Delta? crewDelta, Random rng) {
  if (crewDelta == null) return;
  state.crewCount = _clampCrew(state.crewCount + crewDelta.roll(rng));
}

/// How much a `gamble: true` choice's effects are amplified, purely as a
/// function of how deep into the run it's resolved. The odds of success stay
/// exactly whatever the choice's own `check.difficulty` says — this only
/// scales the STAKES: the same gamble taken early is a modest swing, taken
/// late it's an enormous one, in either direction. The trench doesn't get
/// more forgiving of long shots the deeper you sit in it.
double gambleMultiplier(int cycle) => 1 + cycle * 0.08;

List<StatEffect>? scaleEffects(List<StatEffect>? effects, double multiplier) {
  if (effects == null) return null;
  return effects.map((eff) => StatEffect(stat: eff.stat, delta: eff.delta.scaled(multiplier))).toList();
}

Delta? scaleCrewDelta(Delta? crewDelta, double multiplier) => crewDelta?.scaled(multiplier);

/// How hard a freshly-discovered site's stats skew low (bad) vs high (good),
/// as a function of how far into the run it's found. Early on this is a
/// large exponent, which crushes rolls toward 0; late-game it eases down
/// toward a floor around 0.45, which leans rolls toward the higher end
/// without ever making a high roll the norm. `skewedRandom01` needs power <
/// 1 to skew upward at all, and P(roll > 0.9) at that floor is still only
/// ~1-in-6 per stat — five independent stats all landing that high is a
/// long-tail event even at the floor, by design: playing longer buys better
/// odds, not a guarantee, and a truly "perfect" site stays rare regardless
/// of how far in you are.
double siteSkewPower(int cycle) => max(0.45, 3.2 / (1 + cycle * 0.15));

/// Each Anomaly entry is rolled independently against its own `probability`,
/// so a site can end up with none, one, or several at once. Detected but
/// unexplored — see exploreSiteAnomaly for how a drone resolves one.
List<AnomalyInstance> _rollAnomalies(Random rng) {
  return anomalies_content.anomalies
      .where((a) => rng.nextDouble() < a.probability)
      .map((a) => AnomalyInstance(id: a.id))
      .toList();
}

/// Generates a full geological/oceanic stat distribution for a newly
/// discovered site — one independently-rolled value per SiteStat entry (NOT
/// the habitat's own stats), so a site can be strong on one axis and weak on
/// another. This is what the player weighs when deciding whether to settle,
/// and what settleAtSite blends into the habitat's own stats to determine
/// the ending. Anomalies are rolled alongside, but stay unresolved — their
/// effect on these stats only lands once a drone explores them
/// (exploreSiteAnomaly).
({Map<String, int> stats, List<AnomalyInstance> anomalies}) generateSiteStats(int cycle, Random rng) {
  final power = siteSkewPower(cycle);
  final statsMap = <String, int>{
    for (final s in site_stats_content.siteStats) s.id: (skewedRandom01(power, rng) * 100).round(),
  };
  return (stats: statsMap, anomalies: _rollAnomalies(rng));
}

/// An outcome can surface a new candidate site. Duplicate ids are ignored —
/// an event is normally `once: true` anyway, but this keeps discovery
/// idempotent regardless.
void applyDiscoverSite(GameState state, DiscoverSite? discoverSite, Random rng) {
  if (discoverSite == null || state.sites.any((s) => s.id == discoverSite.id)) return;
  final generated = generateSiteStats(state.cycle, rng);
  state.sites.add(SiteInstance(
    id: discoverSite.id,
    name: discoverSite.name,
    blurb: discoverSite.blurb,
    stats: generated.stats,
    anomalies: generated.anomalies,
  ));
}

/// Spends one recon drone to resolve a single detected-but-unexplored
/// anomaly on `site`: picks one of its variants (weighted, hidden until
/// now), folds that variant's effects into the site's own stats, and locks
/// in the revealed nature/blurb so it displays that way from now on. No-op
/// (returns null) if the anomaly is already explored, unknown, or the
/// player is out of drones — never partially spends a drone.
AnomalyInstance? exploreSiteAnomaly(GameState state, SiteInstance site, String anomalyId, Random rng) {
  if (state.drones <= 0) return null;

  AnomalyInstance? instance;
  for (final a in site.anomalies) {
    if (a.id == anomalyId) {
      instance = a;
      break;
    }
  }
  if (instance == null || instance.explored) return null;

  anomalies_content.Anomaly? def;
  for (final a in anomalies_content.anomalies) {
    if (a.id == anomalyId) {
      def = a;
      break;
    }
  }
  if (def == null) return null;

  state.drones -= 1;
  final variant = _weightedPick(def.variants, (v) => v.weight, rng)!;
  for (final eff in variant.effects ?? const []) {
    site.stats[eff.stat] = _clamp((site.stats[eff.stat] ?? 0) + eff.delta.roll(rng));
  }
  instance.explored = true;
  instance.nature = variant.nature;
  instance.blurb = variant.blurb;
  return instance;
}

/// Resolves a choice: runs an optional skill check (d100 + stat-derived
/// bonus vs difficulty), applies the resulting outcome's effects/flags
/// (scaled up by how deep into the run it is, if the choice is a `gamble`),
/// and returns the outcome text to display plus whether it was a success
/// (for UI flavor).
({String text, bool? succeeded, SiteInstance? discoveredSite}) resolveChoice(
  GameState state,
  GameEvent event,
  Choice choice,
  Random rng,
) {
  Outcome outcome;
  bool? succeeded;

  if (choice.check != null) {
    final bonus = ((state.stats[choice.check!.stat] ?? 0) / 5).round(); // 0-20 bonus
    final roll = rollD100(rng) + bonus;
    succeeded = roll >= choice.check!.difficulty;
    outcome = (succeeded ? choice.outcomes.success : choice.outcomes.failure)!;
  } else {
    outcome = choice.outcomes.defaultOutcome!;
  }

  final multiplier = choice.gamble ? gambleMultiplier(state.cycle) : 1.0;
  final effects = choice.gamble ? scaleEffects(outcome.effects, multiplier) : outcome.effects;
  applyEffects(state, effects, rng);
  applyCrewDelta(
    state,
    choice.gamble ? scaleCrewDelta(outcome.crewDelta, multiplier) : outcome.crewDelta,
    rng,
  );
  if (outcome.setFlags != null) {
    state.flags.addAll(outcome.setFlags!);
  }
  final sitesBefore = state.sites.length;
  applyDiscoverSite(state, outcome.discoverSite, rng);
  final discoveredSite = state.sites.length > sitesBefore ? state.sites.last : null;

  if (event.once) state.usedEventIds.add(event.id);
  state.log.add(outcome.text);
  state.cycle += 1;
  state.siteCountdown -= 1;

  return (text: outcome.text, succeeded: succeeded, discoveredSite: discoveredSite);
}

/// The player-driven ending: settling is available the moment any site has
/// been discovered, independent of the current scenario, and independent of
/// whether the habitat is thriving or falling apart. A site's geology
/// doesn't become the ending directly — each SiteStat entry *influences* one
/// or more habitat stats it plausibly bears on (see site_stats.dart), each
/// by its own weight, nudging the habitat's own final condition toward it. A
/// structurally sound site meaningfully improves the final hull outcome and
/// gives the crew some confidence too; a toxic one drags sanity down and
/// strains the air scrubbers. Neither fully overrides what the habitat
/// already brought with it.
///
/// On top of that blend, any site stat far enough into danger or boon
/// territory (past siteDangerThreshold / siteBoonThreshold) earns its own
/// individualized incident — an extra nudge to whatever it influences,
/// reusing those same weights so a heavier influence takes a heavier hit,
/// plus (where physically plausible) a handful of extra casualties. Each
/// incident is narrated as its own paragraph, so the ending reads like a
/// specific account of what happened at this specific site rather than one
/// canned tier blurb. Pressure Tolerance also decides how many of the crew
/// survive the transition itself, separately from all of the above — a
/// direct casualty count, narrated as its own closing paragraph.
({String id, String title, List<String> paragraphs}) settleAtSite(
  GameState state,
  SiteInstance site,
  Random rng,
) {
  final finalStats = Map<String, int>.from(state.stats);
  for (final target in stats_content.stats) {
    if (target.id == "favour") continue; // corporate standing isn't geography's business
    final contributions = <({int value, double weight})>[];
    for (final ss in site_stats_content.siteStats) {
      for (final inf in ss.influences) {
        if (inf.stat == target.id) {
          contributions.add((value: site.stats[ss.id] ?? 0, weight: inf.weight));
        }
      }
    }
    if (contributions.isEmpty) continue;
    final totalWeight = contributions.fold<double>(0, (sum, c) => sum + c.weight);
    final siteContribution =
        contributions.fold<double>(0, (sum, c) => sum + c.value * c.weight) / totalWeight;
    finalStats[target.id] = ((state.stats[target.id] ?? 0) * 0.4 + siteContribution * 0.6).round();
  }

  var finalCrew = state.crewCount;
  final incidentParagraphs = <String>[];
  for (final ss in site_stats_content.siteStats) {
    final value = site.stats[ss.id] ?? 0;
    final isDanger = value <= site_stats_content.siteDangerThreshold && ss.danger != null;
    final isBoon = !isDanger && value >= site_stats_content.siteBoonThreshold && ss.boon != null;
    if (!isDanger && !isBoon) continue;

    final incident = (isDanger ? ss.danger : ss.boon)!;
    final direction = isDanger ? -1 : 1;
    final distance =
        isDanger ? site_stats_content.siteDangerThreshold - value : value - site_stats_content.siteBoonThreshold;
    for (final inf in ss.influences) {
      finalStats[inf.stat] = _clamp((finalStats[inf.stat] ?? 0) + direction * (distance * inf.weight).round());
    }
    if (incident.crewDelta != null) finalCrew += incident.crewDelta!.roll(rng);
    incidentParagraphs.add(incident.text(site));
  }

  final pressureLoss = ((100 - (site.stats["pressure"] ?? 0)) * 0.3).round(); // 0-30, worse on brutal sites
  finalCrew = max(0, finalCrew - pressureLoss);
  state.crewCount = finalCrew;
  final transitionParagraph = pressureLoss > 0
      ? "The transition itself costs you $pressureLoss more of the crew — the depth change alone is enough, and it is."
      : "Every one of the crew makes the transition intact. At this depth, that's not nothing.";

  final crewScore = min(100.0, (finalCrew / stats_content.startingCrew) * 100);
  final statScore =
      stats_content.stats.fold<int>(0, (sum, s) => sum + (finalStats[s.id] ?? 0)) / stats_content.stats.length;
  final score = (statScore + crewScore) / 2;

  final sorted = [...settlement_content.settlementTiers]..sort((a, b) => b.priority.compareTo(a.priority));
  final tier = sorted.firstWhere(
    (t) => t.matches != null
        ? t.matches!(score, finalCrew, stats_content.startingCrew)
        : score >= t.minScore!,
  );
  return (
    id: "settled_${site.id}_${tier.id}",
    title: tier.title,
    paragraphs: [tier.text(site, finalCrew), ...incidentParagraphs, transitionParagraph],
  );
}

/// Checks stat-zero fail states and scripted endings, highest priority
/// first.
endings_content.Ending? checkEnding(GameState state) {
  final sorted = [...endings_content.endings]..sort((a, b) => b.priority.compareTo(a.priority));
  for (final ending in sorted) {
    if (ending.condition(state)) return ending;
  }
  if (state.cycle > stats_content.maxCycles) {
    for (final e in endings_content.endings) {
      if (e.id == "endurance") return e;
    }
    return null;
  }
  return null;
}
