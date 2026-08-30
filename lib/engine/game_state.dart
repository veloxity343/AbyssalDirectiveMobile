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

  // Mirrors storage.js's saveGame/loadGame exactly, including the
  // Set<->List round-trip for usedEventIds (JSON has no set type) and the
  // back-compat defaults for saves from before drones/site-stats/anomalies
  // existed as fields, so an old local save never crashes on load.
  Map<String, dynamic> toJson() => {
        'directiveNumber': directiveNumber,
        'cycle': cycle,
        'stats': stats,
        'crewCount': crewCount,
        'drones': drones,
        'flags': flags,
        'sites': sites.map((s) => s.toJson()).toList(),
        'siteCountdown': siteCountdown,
        'usedEventIds': usedEventIds.toList(),
        'log': log,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        directiveNumber: json['directiveNumber'] as int,
        cycle: json['cycle'] as int,
        stats: Map<String, int>.from(json['stats'] as Map),
        crewCount: json['crewCount'] as int,
        drones: json['drones'] as int,
        flags: Map<String, bool>.from(json['flags'] as Map),
        sites: (json['sites'] as List? ?? const [])
            .map((s) => SiteInstance.fromJson(s as Map<String, dynamic>))
            .toList(),
        siteCountdown: json['siteCountdown'] as int,
        usedEventIds: Set<String>.from(json['usedEventIds'] as List? ?? const []),
        log: List<String>.from(json['log'] as List? ?? const []),
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'blurb': blurb,
        'stats': stats,
        'anomalies': anomalies.map((a) => a.toJson()).toList(),
      };

  factory SiteInstance.fromJson(Map<String, dynamic> json) => SiteInstance(
        id: json['id'] as String,
        name: json['name'] as String,
        blurb: json['blurb'] as String,
        stats: Map<String, int>.from(json['stats'] as Map),
        // saves predating anomalies never had this field at all.
        anomalies: (json['anomalies'] as List? ?? const [])
            .map((a) => AnomalyInstance.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'explored': explored,
        if (nature != null) 'nature': nature,
        if (blurb != null) 'blurb': blurb,
      };

  factory AnomalyInstance.fromJson(Map<String, dynamic> json) => AnomalyInstance(
        id: json['id'] as String,
        explored: json['explored'] as bool? ?? false,
        nature: json['nature'] as String?,
        blurb: json['blurb'] as String?,
      );
}
