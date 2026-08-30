// Tests for settleAtSite specifically — the blend, the individualized
// danger/boon incident system, and the pressure-transition casualty count.
// Seeded for determinism; see engine_test.dart's header for why. Written and
// reasoned through carefully but never executed in the authoring
// environment (no Dart/Flutter SDK there) — run `flutter test` to confirm.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:abyssal_directive_mobile/content/stats.dart' as stats_content;
import 'package:abyssal_directive_mobile/engine/engine.dart';
import 'package:abyssal_directive_mobile/engine/game_state.dart';

SiteInstance siteWith(Map<String, int> stats, {String id = "test_site", String name = "Test Site"}) {
  return SiteInstance(id: id, name: name, blurb: "blurb", stats: stats, anomalies: []);
}

void main() {
  group('settleAtSite', () {
    test('every site stat past the danger threshold adds its own paragraph', () {
      final state = createInitialState(Random(1));
      // geology, thermal, purity, biotic, pressure all deep in danger territory.
      final site = siteWith({"geology": 5, "thermal": 5, "purity": 5, "biotic": 5, "pressure": 5});
      final result = settleAtSite(state, site, Random(1));

      // tier text + 5 danger incidents + the transition paragraph.
      expect(result.paragraphs, hasLength(7));
    });

    test('every site stat past the boon threshold adds its own paragraph, no extra casualties', () {
      final state = createInitialState(Random(1));
      final site = siteWith({"geology": 95, "thermal": 95, "purity": 95, "biotic": 95, "pressure": 95});
      final crewBefore = state.crewCount;
      final result = settleAtSite(state, site, Random(1));

      expect(result.paragraphs, hasLength(7));
      // Boons never carry a crewDelta — only the (near-zero, since pressure
      // is high) transition loss should apply.
      expect(state.crewCount, greaterThanOrEqualTo(crewBefore - 5));
    });

    test('a site with every stat in the neutral middle adds no incident paragraphs', () {
      final state = createInitialState(Random(1));
      final site = siteWith({"geology": 50, "thermal": 50, "purity": 50, "biotic": 50, "pressure": 50});
      final result = settleAtSite(state, site, Random(1));

      // Just the tier text and the transition paragraph.
      expect(result.paragraphs, hasLength(2));
    });

    test('low pressure costs crew in the transition; the closing paragraph says so', () {
      final state = createInitialState(Random(1));
      final site = siteWith({"geology": 50, "thermal": 50, "purity": 50, "biotic": 50, "pressure": 0});
      final crewBefore = state.crewCount;
      final result = settleAtSite(state, site, Random(1));

      expect(state.crewCount, lessThan(crewBefore));
      expect(result.paragraphs.last, contains("costs you"));
    });

    test('perfect pressure (100) loses no crew in the transition and says so', () {
      final state = createInitialState(Random(1));
      final site = siteWith({"geology": 50, "thermal": 50, "purity": 50, "biotic": 50, "pressure": 100});
      final crewBefore = state.crewCount;
      final result = settleAtSite(state, site, Random(1));

      expect(state.crewCount, crewBefore); // 0 pressureLoss, and no danger/boon crewDelta at pressure=100...
      // (100 is a boon for pressure, but pressure's boon carries no crewDelta by design)
      expect(result.paragraphs.last, "Every one of the crew makes the transition intact. At this depth, that's not nothing.");
    });

    test('the settlement id is namespaced by site id and resolved tier', () {
      final state = createInitialState(Random(1));
      final site = siteWith({"geology": 50, "thermal": 50, "purity": 50, "biotic": 50, "pressure": 50}, id: "my_site");
      final result = settleAtSite(state, site, Random(1));
      expect(result.id, startsWith("settled_my_site_"));
    });

    test('a uniformly excellent site with a strong, already-grown habitat reaches flourishing', () {
      final state = createInitialState(Random(1));
      for (final s in stats_content.stats) {
        state.stats[s.id] = 90;
      }
      // "flourishing" requires finalCrew > startingCrew, which settleAtSite
      // itself can never produce (it only ever holds crew steady or costs
      // it) — simulate a habitat that already grew past its start via the
      // Refugees chain earlier in the run. Pressure at 100 keeps the
      // transition loss at exactly 0 so this stays deterministic.
      state.crewCount = stats_content.startingCrew + 60;
      final site = siteWith({"geology": 90, "thermal": 90, "purity": 90, "biotic": 90, "pressure": 100});
      final result = settleAtSite(state, site, Random(1));
      expect(result.title, "Not Just Shelter — A Colony");
    });

    test('a uniformly terrible, already-depleted habitat lands on the doomed tier', () {
      final state = createInitialState(Random(1));
      for (final s in stats_content.stats) {
        state.stats[s.id] = 0;
      }
      // Start crew low enough that even the best-case (least negative)
      // danger-incident rolls plus the pressure-transition loss are
      // guaranteed to floor finalCrew at 0 — keeps crewScore deterministic
      // instead of straddling a tier boundary depending on RNG.
      state.crewCount = 10;
      final site = siteWith({"geology": 0, "thermal": 0, "purity": 0, "biotic": 0, "pressure": 0});
      final result = settleAtSite(state, site, Random(1));
      expect(result.title, "A Grave of Your Choosing");
    });
  });
}
