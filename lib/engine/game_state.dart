// Runtime state shapes — mirrors the state shape documented at the top of
// the web prototype's engine.js. Pure data only, no game-logic functions
// (those land in engine.dart in the next phase). Lives under engine/ rather
// than content/ because it's runtime state, not a content definition — but
// content/*.dart imports it for closures that need to reference the current
// run or a specific site (an ending's `condition`, a site stat's
// `danger`/`boon` narrative text). That's a one-way dependency (content ->
// this file); this file never imports anything from content/, so there's no
// cycle.
//
// Serialization (toJson/fromJson, mirroring storage.js) is intentionally not
// here yet — that's part of the storage_service.dart phase, not needed for
// content/*.dart to compile against these shapes.

class GameState {
  final int directiveNumber;
  int cycle;
  final Map<String, int> stats;
  int crewCount;
  int drones;
  final Map<String, bool> flags;
  final List<SiteInstance> sites;
  int siteCountdown;
  final Set<String> usedEventIds;
  final List<String> log;

  GameState({
    required this.directiveNumber,
    required this.cycle,
    required this.stats,
    required this.crewCount,
    required this.drones,
    required this.flags,
    required this.sites,
    required this.siteCountdown,
    required this.usedEventIds,
    required this.log,
  });
}

/// A discovered candidate site — one independently-rolled value per
/// SITE_STATS entry (see content/site_stats.dart), plus whatever anomalies
/// were detected on it. `stats` and each `AnomalyInstance`'s fields are
/// mutated in place (by exploreSiteAnomaly / settleAtSite, once engine.dart
/// exists) rather than replaced, matching the JS version's mutable objects.
class SiteInstance {
  final String id;
  final String name;
  final String blurb;
  final Map<String, int> stats;
  final List<AnomalyInstance> anomalies;

  SiteInstance({
    required this.id,
    required this.name,
    required this.blurb,
    required this.stats,
    required this.anomalies,
  });
}

/// A single detected-but-maybe-not-yet-explored anomaly on a site. Starts
/// with only `id` known; `explored`/`nature`/`blurb` are filled in once a
/// drone reveals it (see content/anomalies.dart for what `nature` values and
/// resolved `blurb` text look like).
class AnomalyInstance {
  final String id;
  bool explored;
  String? nature;
  String? blurb;

  AnomalyInstance({
    required this.id,
    this.explored = false,
    this.nature,
    this.blurb,
  });
}
