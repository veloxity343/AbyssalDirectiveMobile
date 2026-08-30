// Anomalies are a site's incidental features — not a stat axis of their own
// (unlike SiteStat), just things that happen to be detected nearby. Each one
// is rolled independently by its own `probability` when a site is generated
// (see generateSiteStats, once engine.dart exists), so a site can turn up
// none, one, or several at once.
//
// A detected anomaly starts unexplored: the player sees only `label` and
// `detectedBlurb` — a sensor-only description that deliberately doesn't say
// whether it's good news. Its true nature is hidden until the player spends
// a recon drone to explore it (exploreSiteAnomaly), at which point one of
// its `variants` is picked (weighted by `weight`, relative within that
// anomaly only) and locked in: the resolved `blurb` replaces the detected
// one, and `effects` (if any) are folded into the site's own SiteStat
// values, same scale as a normal roll (0-100, clamped). A variant can carry
// no `effects` at all for a neutral outcome that's flavor only. Drones are a
// limited consumable (see startingDrones in stats.dart) — exploring is a
// real cost, not a free peek.
//
// Ported 1:1 from the web prototype's src/content/anomalies.js.

import 'effects.dart';

class AnomalyVariant {
  final String nature; // "positive" | "neutral" | "negative"
  final int weight;
  final String blurb;
  final List<StatEffect>? effects;
  const AnomalyVariant({
    required this.nature,
    required this.weight,
    required this.blurb,
    this.effects,
  });
}

class Anomaly {
  final String id;
  final String label;
  final double probability;
  final String detectedBlurb;
  final List<AnomalyVariant> variants;
  const Anomaly({
    required this.id,
    required this.label,
    required this.probability,
    required this.detectedBlurb,
    required this.variants,
  });
}

const List<Anomaly> anomalies = [
  Anomaly(
    id: "native_fauna",
    label: "Native Fauna",
    probability: 0.16,
    detectedBlurb:
        "Something's moving out past the floodlights — schools, maybe, or a single shape reading as several contacts at once.",
    variants: [
      AnomalyVariant(
        nature: "positive",
        weight: 3,
        blurb: "Harmless shoals, thick and undisturbed — a real food chain, this deep.",
        effects: [StatEffect(stat: "biotic", delta: Delta.fixed(14))],
      ),
      AnomalyVariant(
        nature: "neutral",
        weight: 2,
        blurb: "Just fish. Bigger than expected, otherwise unremarkable.",
      ),
      AnomalyVariant(
        nature: "negative",
        weight: 1,
        blurb: "It's not shoaling. It's stalking. Whatever it is, give the site a wide berth.",
        effects: [StatEffect(stat: "pressure", delta: Delta.fixed(-16))],
      ),
    ],
  ),
  Anomaly(
    id: "apex_predator",
    label: "Something Larger",
    probability: 0.06,
    detectedBlurb:
        "One sonar contact keeps returning too big to be a school, circling just past the edge of the lights.",
    variants: [
      AnomalyVariant(
        nature: "positive",
        weight: 1,
        blurb:
            "It's territorial, not hostile — and it's keeping everything smaller and hungrier away from the site.",
        effects: [StatEffect(stat: "biotic", delta: Delta.fixed(8))],
      ),
      AnomalyVariant(
        nature: "neutral",
        weight: 2,
        blurb: "Big, slow, and uninterested. It passes through once a cycle and never comes closer.",
      ),
      AnomalyVariant(
        nature: "negative",
        weight: 3,
        blurb:
            "It's fed on something down here before, and recently. Building on this site means building next to it.",
        effects: [StatEffect(stat: "pressure", delta: Delta.fixed(-22))],
      ),
    ],
  ),
  Anomaly(
    id: "vent_field",
    label: "Hydrothermal Vents",
    probability: 0.12,
    detectedBlurb: "Heat blooms on the thermal overlay — a smear too regular to be a fluke reading.",
    variants: [
      AnomalyVariant(
        nature: "positive",
        weight: 2,
        blurb: "A stable vent system, geothermal and tappable, sitting well clear of the site's actual footing.",
        effects: [StatEffect(stat: "thermal", delta: Delta.fixed(10))],
      ),
      AnomalyVariant(
        nature: "neutral",
        weight: 2,
        blurb: "Vents, confirmed — venting exactly as much heat as expected and no more.",
      ),
      AnomalyVariant(
        nature: "negative",
        weight: 2,
        blurb: "The vent field runs closer to the substrate than the scan suggested. The ground here won't stay put.",
        effects: [
          StatEffect(stat: "thermal", delta: Delta.fixed(-14)),
          StatEffect(stat: "geology", delta: Delta.fixed(-10)),
        ],
      ),
    ],
  ),
  Anomaly(
    id: "kelp_forest",
    label: "A Drowned Forest",
    probability: 0.18,
    detectedBlurb: "Dense growth carpets a section of the ridge, too thick to identify from the hull cams alone.",
    variants: [
      AnomalyVariant(
        nature: "positive",
        weight: 3,
        blurb: "A real kelp-analog forest — oxygenating, edible, thriving.",
        effects: [
          StatEffect(stat: "biotic", delta: Delta.fixed(12)),
          StatEffect(stat: "purity", delta: Delta.fixed(6)),
        ],
      ),
      AnomalyVariant(
        nature: "neutral",
        weight: 2,
        blurb: "Inedible scrub. Alive, but not useful to anyone.",
      ),
      AnomalyVariant(
        nature: "negative",
        weight: 1,
        blurb: "It's a bloom, not a forest — and it's souring the water around it.",
        effects: [StatEffect(stat: "purity", delta: Delta.fixed(-12))],
      ),
    ],
  ),
  Anomaly(
    id: "active_fissure",
    label: "An Open Fissure",
    probability: 0.1,
    detectedBlurb: "A hairline crack shows up on the seafloor scan, longer than last pass and still moving.",
    variants: [
      AnomalyVariant(
        nature: "positive",
        weight: 1,
        blurb: "Already settled — an old fissure, sealed and inert, no threat to anything built nearby.",
        effects: [StatEffect(stat: "geology", delta: Delta.fixed(8))],
      ),
      AnomalyVariant(
        nature: "neutral",
        weight: 2,
        blurb: "Active, but shallow. Worth noting, not worth panicking over.",
      ),
      AnomalyVariant(
        nature: "negative",
        weight: 3,
        blurb: "It's widening. Whatever gets built near it won't be standing on solid ground for long.",
        effects: [StatEffect(stat: "geology", delta: Delta.fixed(-20))],
      ),
    ],
  ),
  Anomaly(
    id: "ancient_ruins",
    label: "Something Built This",
    probability: 0.05,
    detectedBlurb: "Shapes on the sonar return too regular for geology, too old for corporate salvage.",
    variants: [
      AnomalyVariant(
        nature: "positive",
        weight: 2,
        blurb: "Ancient, but sound — whoever built it built to last, and the ground under it shows it.",
        effects: [StatEffect(stat: "geology", delta: Delta.fixed(10))],
      ),
      AnomalyVariant(
        nature: "neutral",
        weight: 2,
        blurb: "Ruins, confirmed. Nothing worth the dive, but a curiosity for the log.",
      ),
      AnomalyVariant(
        nature: "negative",
        weight: 1,
        blurb: "Old construction, and old contamination with it — the water nearby tests wrong.",
        effects: [StatEffect(stat: "purity", delta: Delta.fixed(-14))],
      ),
    ],
  ),
  Anomaly(
    id: "symmetrical_basin",
    label: "A Perfect Basin",
    probability: 0.09,
    detectedBlurb:
        "A basin near the site reads a little too round on the topographic scan for erosion to explain.",
    variants: [
      AnomalyVariant(
        nature: "positive",
        weight: 1,
        blurb: "A natural catch basin — it's actually improving runoff and sediment settling nearby.",
        effects: [StatEffect(stat: "purity", delta: Delta.fixed(8))],
      ),
      AnomalyVariant(
        nature: "neutral",
        weight: 3,
        blurb: "Just a basin. Odd shape, no explanation, no consequence.",
      ),
      AnomalyVariant(
        nature: "negative",
        weight: 1,
        blurb: "It's a sinkhole in slow motion — it's been eating the shelf around it for years.",
        effects: [StatEffect(stat: "geology", delta: Delta.fixed(-10))],
      ),
    ],
  ),
];
