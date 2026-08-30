import 'dart:math';

// A stat/crew delta is either a fixed number or a [min, max] range rolled
// uniformly at apply time — mirrors the JS content's
// `Array.isArray(delta) ? roll(delta) : delta` pattern (see engine.js's
// rollRange), just made explicit as a type instead of an untyped union.
sealed class Delta {
  const Delta();
  const factory Delta.fixed(int value) = FixedDelta;
  const factory Delta.range(int min, int max) = RangeDelta;

  int roll(Random rng);

  // Amplifies the stakes of a `gamble: true` choice — replaces
  // scaleEffects/scaleCrewDelta from the JS engine. Only ever called on
  // event effects, never on the site-stat danger/boon incidents.
  Delta scaled(double multiplier);
}

class FixedDelta extends Delta {
  final int value;
  const FixedDelta(this.value);

  @override
  int roll(Random rng) => value;

  @override
  Delta scaled(double multiplier) => FixedDelta((value * multiplier).round());
}

class RangeDelta extends Delta {
  final int min;
  final int max;
  const RangeDelta(this.min, this.max);

  @override
  int roll(Random rng) => (min + rng.nextDouble() * (max - min)).round();

  @override
  Delta scaled(double multiplier) =>
      RangeDelta((min * multiplier).round(), (max * multiplier).round());
}

/// A named stat nudge — `{stat, delta}` in the JS content, used for both a
/// choice outcome's `effects` and an anomaly variant's `effects`.
class StatEffect {
  final String stat;
  final Delta delta;
  const StatEffect({required this.stat, required this.delta});
}
