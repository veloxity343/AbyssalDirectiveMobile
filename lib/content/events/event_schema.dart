// Event/choice/outcome schema — ported 1:1 from the web prototype's
// src/content/events/index.js header comment.
//
// crewDelta is a raw headcount change applied to GameState.crewCount
// (starts at startingCrew, see stats.dart), separate from `effects` since
// crew isn't a 0-100 gauge. Negative for scenarios that cost lives; positive
// for rescues/proliferation. Scales with `gamble` the same as `effects`
// does (see Delta.scaled in effects.dart).
//
// discoverSite: { id, name, blurb } is all content provides. The site's
// stat distribution is its own geological/oceanic axis set (site_stats.dart),
// NOT the habitat's stats — rolled by the engine at discovery time from the
// current cycle, not authored here.
//
// gamble: true (only meaningful alongside `check`) — the odds stay exactly
// whatever `difficulty` says (authored high, ~78-82, so success is a genuine
// long shot regardless of cycle), but the engine scales the resulting
// effects up the deeper into the run the choice is resolved. Author
// success/failure effects at their cycle-1 "base" magnitude — the same
// gamble taken later can swing several times harder, either way. These
// choices are kept repeatable (no `once`) so the escalation is visible
// within a single playthrough.

import '../effects.dart';

/// Gates whether an event/choice is eligible. All present fields must hold
/// (AND, not OR) for a requirement to be met.
class Requirement {
  final String? stat;
  final int? min;
  final int? max;
  final String? flag;
  final bool? flagIs; // defaults to true when flag is set and this is null
  final int? cycleMin;
  final int? cycleMax;
  const Requirement({
    this.stat,
    this.min,
    this.max,
    this.flag,
    this.flagIs,
    this.cycleMin,
    this.cycleMax,
  });
}

/// d100 + (stat/5) vs difficulty, rolled once per choice resolution.
class SkillCheck {
  final String stat;
  final int difficulty;
  const SkillCheck({required this.stat, required this.difficulty});
}

class DiscoverSite {
  final String id;
  final String name;
  final String blurb;
  const DiscoverSite({required this.id, required this.name, required this.blurb});
}

class Outcome {
  final String text;
  final List<StatEffect>? effects;
  final Delta? crewDelta;
  final Map<String, bool>? setFlags;
  final DiscoverSite? discoverSite;
  const Outcome({
    required this.text,
    this.effects,
    this.crewDelta,
    this.setFlags,
    this.discoverSite,
  });
}

/// Exactly one of two shapes is populated per choice: `defaultOutcome` alone
/// (no check), or `success`+`failure` together (has a check). `default` is a
/// reserved word in Dart, hence the rename from the JS field name.
class Outcomes {
  final Outcome? defaultOutcome;
  final Outcome? success;
  final Outcome? failure;
  const Outcomes({this.defaultOutcome, this.success, this.failure});
}

class Choice {
  final String label;
  final SkillCheck? check;
  final bool gamble;
  final Outcomes outcomes;
  const Choice({
    required this.label,
    this.check,
    this.gamble = false,
    required this.outcomes,
  });
}

class GameEvent {
  final String id;
  final String title;
  final String text;
  final int weight; // biases the random draw
  final bool once; // true = never reappears after being drawn
  final bool isSiteDiscovery; // true = eligible for the forced site-cadence draw
  final List<Requirement>? requirements;
  final List<Choice> choices;
  const GameEvent({
    required this.id,
    required this.title,
    required this.text,
    this.weight = 1,
    this.once = false,
    this.isSiteDiscovery = false,
    this.requirements,
    required this.choices,
  });
}
