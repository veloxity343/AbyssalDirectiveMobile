// Structural invariants over the ported content — id uniqueness, outcome
// shape, weight/probability sanity. These catch content authoring mistakes
// independent of any engine logic (e.g. a typo'd duplicate id, or a choice
// missing an outcome branch it needs). Written and reasoned through
// carefully but never executed in the authoring environment (no
// Dart/Flutter SDK there) — run `flutter test` to confirm.

import 'package:flutter_test/flutter_test.dart';

import 'package:abyssal_directive_mobile/content/anomalies.dart';
import 'package:abyssal_directive_mobile/content/endings.dart';
import 'package:abyssal_directive_mobile/content/events/events.dart';
import 'package:abyssal_directive_mobile/content/settlement.dart';
import 'package:abyssal_directive_mobile/content/site_stats.dart';
import 'package:abyssal_directive_mobile/content/stats.dart';

void main() {
  group('stats', () {
    test('every stat starts within 0-100', () {
      for (final s in stats) {
        expect(s.start, inInclusiveRange(0, 100));
      }
    });

    test('stat ids are unique', () {
      final ids = stats.map((s) => s.id).toSet();
      expect(ids.length, stats.length);
    });
  });

  group('siteStats', () {
    test('site stat ids are unique', () {
      final ids = siteStats.map((s) => s.id).toSet();
      expect(ids.length, siteStats.length);
    });

    test('every influence weight is positive', () {
      for (final ss in siteStats) {
        for (final inf in ss.influences) {
          expect(inf.weight, greaterThan(0));
        }
      }
    });

    test('siteDangerThreshold is below siteBoonThreshold', () {
      expect(siteDangerThreshold, lessThan(siteBoonThreshold));
    });
  });

  group('anomalies', () {
    test('anomaly ids are unique', () {
      final ids = anomalies.map((a) => a.id).toSet();
      expect(ids.length, anomalies.length);
    });

    test('every probability is in (0, 1]', () {
      for (final a in anomalies) {
        expect(a.probability, greaterThan(0));
        expect(a.probability, lessThanOrEqualTo(1));
      }
    });

    test('every anomaly has at least one variant, each with a positive weight', () {
      for (final a in anomalies) {
        expect(a.variants, isNotEmpty);
        for (final v in a.variants) {
          expect(v.weight, greaterThan(0));
          expect(v.nature, anyOf("positive", "neutral", "negative"));
        }
      }
    });
  });

  group('settlementTiers', () {
    test('tier ids are unique', () {
      final ids = settlementTiers.map((t) => t.id).toSet();
      expect(ids.length, settlementTiers.length);
    });

    test('every tier has either matches or minScore, not neither', () {
      for (final t in settlementTiers) {
        expect(t.matches != null || t.minScore != null, isTrue, reason: "tier '${t.id}' has neither");
      }
    });
  });

  group('endings', () {
    test('ending ids are unique', () {
      final ids = endings.map((e) => e.id).toSet();
      expect(ids.length, endings.length);
    });
  });

  group('events', () {
    test('event ids are unique across every category', () {
      final ids = events.map((e) => e.id).toSet();
      expect(ids.length, events.length);
    });

    test('every event has at least one choice', () {
      for (final e in events) {
        expect(e.choices, isNotEmpty, reason: "event '${e.id}' has no choices");
      }
    });

    test('every event weight is positive', () {
      for (final e in events) {
        expect(e.weight, greaterThan(0), reason: "event '${e.id}' has non-positive weight");
      }
    });

    test('a choice has a check with success+failure, or no check with only a default', () {
      for (final e in events) {
        for (final c in e.choices) {
          if (c.check != null) {
            expect(c.outcomes.success, isNotNull, reason: "${e.id} -> '${c.label}' has a check but no success");
            expect(c.outcomes.failure, isNotNull, reason: "${e.id} -> '${c.label}' has a check but no failure");
            expect(c.outcomes.defaultOutcome, isNull, reason: "${e.id} -> '${c.label}' has both a check and a default");
          } else {
            expect(c.outcomes.defaultOutcome, isNotNull, reason: "${e.id} -> '${c.label}' has no check and no default");
            expect(c.outcomes.success, isNull, reason: "${e.id} -> '${c.label}' has no check but a success branch");
            expect(c.outcomes.failure, isNull, reason: "${e.id} -> '${c.label}' has no check but a failure branch");
          }
        }
      }
    });

    test('a gamble choice always has a check (odds must come from somewhere)', () {
      for (final e in events) {
        for (final c in e.choices) {
          if (c.gamble) {
            expect(c.check, isNotNull, reason: "${e.id} -> '${c.label}' is a gamble with no check");
          }
        }
      }
    });

    test('discoverSite ids are unique across the whole event pool', () {
      final siteIds = <String>[];
      for (final e in events) {
        for (final c in e.choices) {
          for (final outcome in [c.outcomes.defaultOutcome, c.outcomes.success, c.outcomes.failure]) {
            final id = outcome?.discoverSite?.id;
            if (id != null) siteIds.add(id);
          }
        }
      }
      expect(siteIds.toSet().length, siteIds.length);
    });
  });
}
