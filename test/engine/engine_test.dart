// Engine logic tests. Every test seeds its own `Random` so results are
// deterministic and reproducible — a property the JS original never had,
// since it always reached for the global `Math.random()`. These were
// written and reasoned through carefully but never actually executed in the
// environment that authored them (no Dart/Flutter SDK there) — run
// `flutter test` to confirm they pass as written.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:abyssal_directive_mobile/content/stats.dart' as stats_content;
import 'package:abyssal_directive_mobile/content/events/event_schema.dart';
import 'package:abyssal_directive_mobile/content/effects.dart';
import 'package:abyssal_directive_mobile/engine/engine.dart';
import 'package:abyssal_directive_mobile/engine/game_state.dart';

void main() {
  group('createInitialState', () {
    test('starts every stat at its defined starting value', () {
      final state = createInitialState(Random(1));
      for (final s in stats_content.stats) {
        expect(state.stats[s.id], s.start);
      }
    });

    test('starts crew and drones at their content-defined amounts', () {
      final state = createInitialState(Random(1));
      expect(state.crewCount, stats_content.startingCrew);
      expect(state.drones, stats_content.startingDrones);
    });

    test('starts on cycle 1 with no sites, flags, or used events', () {
      final state = createInitialState(Random(1));
      expect(state.cycle, 1);
      expect(state.sites, isEmpty);
      expect(state.flags, isEmpty);
      expect(state.usedEventIds, isEmpty);
    });

    test('siteCountdown is always 1, 2, or 3', () {
      for (var seed = 0; seed < 50; seed++) {
        final state = createInitialState(Random(seed));
        expect(state.siteCountdown, inInclusiveRange(1, 3));
      }
    });

    test('respects an explicitly passed directiveNumber instead of rolling one', () {
      final state = createInitialState(Random(1), directiveNumber: 42);
      expect(state.directiveNumber, 42);
    });

    test('rolls a directiveNumber in [1, 999] when none is passed', () {
      for (var seed = 0; seed < 50; seed++) {
        final state = createInitialState(Random(seed));
        expect(state.directiveNumber, inInclusiveRange(1, 999));
      }
    });
  });

  group('requirementsMet', () {
    GameState stateWith({int hull = 70, Map<String, bool>? flags, int cycle = 1}) {
      final state = createInitialState(Random(1));
      state.stats["hull"] = hull;
      if (flags != null) state.flags.addAll(flags);
      state.cycle = cycle;
      return state;
    }

    test('null requirements always pass', () {
      expect(requirementsMet(null, stateWith()), isTrue);
    });

    test('stat min/max gate correctly', () {
      final req = [Requirement(stat: "hull", min: 40, max: 60)];
      expect(requirementsMet(req, stateWith(hull: 50)), isTrue);
      expect(requirementsMet(req, stateWith(hull: 39)), isFalse);
      expect(requirementsMet(req, stateWith(hull: 61)), isFalse);
    });

    test('flag defaults to requiring true, honors explicit flagIs: false', () {
      final wantsTrue = [Requirement(flag: "foundAnomaly")];
      final wantsFalse = [Requirement(flag: "foundAnomaly", flagIs: false)];
      expect(requirementsMet(wantsTrue, stateWith(flags: {"foundAnomaly": true})), isTrue);
      expect(requirementsMet(wantsTrue, stateWith()), isFalse); // unset flag == false
      expect(requirementsMet(wantsFalse, stateWith()), isTrue);
    });

    test('cycleMin/cycleMax gate correctly', () {
      final req = [Requirement(cycleMin: 5, cycleMax: 10)];
      expect(requirementsMet(req, stateWith(cycle: 7)), isTrue);
      expect(requirementsMet(req, stateWith(cycle: 4)), isFalse);
      expect(requirementsMet(req, stateWith(cycle: 11)), isFalse);
    });

    test('multiple requirements are ANDed together', () {
      final req = [Requirement(stat: "hull", min: 50), Requirement(cycleMin: 5)];
      expect(requirementsMet(req, stateWith(hull: 60, cycle: 6)), isTrue);
      expect(requirementsMet(req, stateWith(hull: 60, cycle: 2)), isFalse);
      expect(requirementsMet(req, stateWith(hull: 10, cycle: 6)), isFalse);
    });
  });

  group('resolveChoice', () {
    test('a checkless choice always applies its default outcome', () {
      final state = createInitialState(Random(1));
      final event = GameEvent(
        id: "test_event",
        title: "Test",
        text: "test",
        choices: [
          Choice(
            label: "do it",
            outcomes: Outcomes(
              defaultOutcome: Outcome(
                text: "done",
                effects: [StatEffect(stat: "hull", delta: const Delta.fixed(10))],
                crewDelta: const Delta.fixed(-5),
              ),
            ),
          ),
        ],
      );
      final before = state.stats["hull"]!;
      final crewBefore = state.crewCount;
      final result = resolveChoice(state, event, event.choices[0], Random(1));

      expect(result.text, "done");
      expect(result.succeeded, isNull);
      expect(state.stats["hull"], before + 10);
      expect(state.crewCount, crewBefore - 5);
      expect(state.cycle, 2); // advances exactly one cycle
    });

    test('a checked choice resolves to success or failure and never both', () {
      final state = createInitialState(Random(1));
      state.stats["hull"] = 100; // max +20 bonus, so a low difficulty always succeeds
      final event = GameEvent(
        id: "test_event",
        title: "Test",
        text: "test",
        choices: [
          Choice(
            label: "try",
            check: SkillCheck(stat: "hull", difficulty: 1), // trivially easy given the bonus
            outcomes: Outcomes(
              success: Outcome(text: "won"),
              failure: Outcome(text: "lost"),
            ),
          ),
        ],
      );
      final result = resolveChoice(state, event, event.choices[0], Random(2));
      expect(result.succeeded, isTrue);
      expect(result.text, "won");
    });

    test('a once event is marked used after resolving', () {
      final state = createInitialState(Random(1));
      final event = GameEvent(
        id: "test_event",
        title: "Test",
        text: "test",
        once: true,
        choices: [
          Choice(label: "do it", outcomes: Outcomes(defaultOutcome: Outcome(text: "done"))),
        ],
      );
      resolveChoice(state, event, event.choices[0], Random(1));
      expect(state.usedEventIds.contains("test_event"), isTrue);
    });

    test('discoverSite adds a new site and is reported back as discoveredSite', () {
      final state = createInitialState(Random(1));
      final event = GameEvent(
        id: "test_event",
        title: "Test",
        text: "test",
        choices: [
          Choice(
            label: "survey",
            outcomes: Outcomes(
              defaultOutcome: Outcome(
                text: "found something",
                discoverSite: DiscoverSite(id: "test_site", name: "Test Site", blurb: "blurb"),
              ),
            ),
          ),
        ],
      );
      final result = resolveChoice(state, event, event.choices[0], Random(1));
      expect(state.sites, hasLength(1));
      expect(result.discoveredSite?.id, "test_site");
      // A site's own stats are always in [0, 100] regardless of cycle/RNG.
      for (final v in state.sites.first.stats.values) {
        expect(v, inInclusiveRange(0, 100));
      }
    });
  });

  group('exploreSiteAnomaly', () {
    test('spends exactly one drone and reveals the anomaly', () {
      final state = createInitialState(Random(1));
      final site = SiteInstance(
        id: "s1",
        name: "Site",
        blurb: "b",
        stats: {"geology": 50, "thermal": 50, "purity": 50, "biotic": 50, "pressure": 50},
        anomalies: [AnomalyInstance(id: "kelp_forest")],
      );
      final dronesBefore = state.drones;
      final result = exploreSiteAnomaly(state, site, "kelp_forest", Random(1));

      expect(result, isNotNull);
      expect(state.drones, dronesBefore - 1);
      expect(site.anomalies.first.explored, isTrue);
      expect(site.anomalies.first.nature, isNotNull);
    });

    test('is a no-op on an already-explored anomaly (does not spend a second drone)', () {
      final state = createInitialState(Random(1));
      final site = SiteInstance(
        id: "s1",
        name: "Site",
        blurb: "b",
        stats: {"geology": 50, "thermal": 50, "purity": 50, "biotic": 50, "pressure": 50},
        anomalies: [AnomalyInstance(id: "kelp_forest")],
      );
      exploreSiteAnomaly(state, site, "kelp_forest", Random(1));
      final dronesAfterFirst = state.drones;
      final second = exploreSiteAnomaly(state, site, "kelp_forest", Random(1));

      expect(second, isNull);
      expect(state.drones, dronesAfterFirst);
    });

    test('is a no-op when out of drones', () {
      final state = createInitialState(Random(1));
      state.drones = 0;
      final site = SiteInstance(
        id: "s1",
        name: "Site",
        blurb: "b",
        stats: {"geology": 50, "thermal": 50, "purity": 50, "biotic": 50, "pressure": 50},
        anomalies: [AnomalyInstance(id: "kelp_forest")],
      );
      expect(exploreSiteAnomaly(state, site, "kelp_forest", Random(1)), isNull);
    });
  });

  group('checkEnding', () {
    test('a stat hitting zero triggers its matching ending', () {
      final state = createInitialState(Random(1));
      state.stats["hull"] = 0;
      final ending = checkEnding(state);
      expect(ending?.id, "implosion");
    });

    test('past maxCycles with no stat-zero falls back to endurance', () {
      final state = createInitialState(Random(1));
      state.cycle = stats_content.maxCycles + 1;
      final ending = checkEnding(state);
      expect(ending?.id, "endurance");
    });

    test('returns null when nothing is triggered', () {
      final state = createInitialState(Random(1));
      expect(checkEnding(state), isNull);
    });
  });
}
