// Stat definitions. Every stat is a 0-100 gauge; hitting 0 (or occasionally
// 100) on certain stats can trigger a bad ending — see endings.dart.
// Ported 1:1 from the web prototype's src/content/stats.js.

class StatDef {
  final String id;
  final String label;
  final int start;
  const StatDef({required this.id, required this.label, required this.start});
}

/// A raw-count row's display label (crew, drones) — not a 0-100 gauge, so it
/// carries no `start`.
class StatDisplay {
  final String id;
  final String label;
  const StatDisplay({required this.id, required this.label});
}

const List<StatDef> stats = [
  StatDef(id: "hull", label: "Hull Integrity", start: 70),
  StatDef(id: "oxygen", label: "Oxygen Reserves", start: 80),
  StatDef(id: "sanity", label: "Crew Sanity", start: 65),
  StatDef(id: "supplies", label: "Supplies", start: 60),
  StatDef(id: "favour", label: "Corporate Standing", start: 50),
];

/// Surviving this long triggers the "Endurance" ending.
const int maxCycles = 30;

// Crew count is tracked separately from the 0-100 stats above — it's a raw
// headcount, not a gauge, and (unlike the stats) it can grow past its start
// via a proliferation chain rather than only ever draining.
const int startingCrew = 200;
const StatDisplay crewDisplay = StatDisplay(id: "crew", label: "Crew Aboard");

// Recon drones are a consumable, not a gauge: each one spent identifies a
// single detected anomaly at a site (see anomalies.dart / exploreSiteAnomaly
// once engine.dart exists). The pool never refills.
const int startingDrones = 10;
const StatDisplay droneDisplay = StatDisplay(id: "drones", label: "Recon Drones");
