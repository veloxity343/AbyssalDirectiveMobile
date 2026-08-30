// A settlement tier is picked (by settleAtSite, once engine.dart exists)
// from a score blended between the habitat's final stats (each nudged by
// the site stats that influence it — see site_stats.dart) and how much of
// the crew survived the transition. Tiers are tried highest `priority`
// first; a tier with `matches(score, finalCrew, startingCrew)` is a
// special-case check (used for "flourishing," which needs more than just a
// high score), while a plain `minScore` is the normal threshold the rest
// use.
//
// Ported 1:1 from the web prototype's src/content/settlement.js.

import '../engine/game_state.dart';

class SettlementTier {
  final String id;
  final int priority;
  final bool Function(double score, int finalCrew, int startingCrew)? matches;
  final int? minScore;
  final String title;
  final String Function(SiteInstance site, int finalCrew) text;
  const SettlementTier({
    required this.id,
    required this.priority,
    this.matches,
    this.minScore,
    required this.title,
    required this.text,
  });
}

final List<SettlementTier> settlementTiers = [
  SettlementTier(
    id: "flourishing",
    priority: 100,
    matches: (score, finalCrew, startingCrew) => score >= 65 && finalCrew > startingCrew,
    title: "Not Just Shelter — A Colony",
    text: (site, finalCrew) =>
        "${site.name} doesn't just hold — it grows. What started as a habitat crew is closer to a town now, $finalCrew strong and still counting. Corporate's ledgers have no line item for what this actually is anymore, and for once that feels like it's working in your favor.",
  ),
  SettlementTier(
    id: "thriving",
    priority: 70,
    minScore: 70,
    title: "A Place Worth Staying",
    text: (site, finalCrew) =>
        "${site.name} takes to the crew fast — steady footing, breathable margins, room to grow past whatever corporate projected in its quarterly models. All $finalCrew of you file the coordinates as home. For the first time since the descent, corporate isn't the only thing keeping you alive.",
  ),
  SettlementTier(
    id: "precarious",
    priority: 40,
    minScore: 40,
    title: "Good Enough to Hold",
    text: (site, finalCrew) =>
        "${site.name} isn't what anyone dreamed about during training. It's stable enough, most days. The $finalCrew who made it this far adjust, the way people do to a compromise nobody let them argue about — and it holds, for now, which is more than the trench usually offers.",
  ),
  SettlementTier(
    id: "doomed",
    priority: 0,
    minScore: 0,
    title: "A Grave of Your Choosing",
    text: (site, finalCrew) =>
        "${site.name} was never going to hold long-term, and everyone down here knew it before you gave the order. Of the crew who started this directive, $finalCrew are left to find that out. At least this ending is the one you picked, not the one the pressure picked for you.",
  ),
];
