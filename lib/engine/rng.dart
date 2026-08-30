// Ported 1:1 from the web prototype's src/rng.js — with one deliberate
// change: every function here takes an explicit `Random rng` instead of
// reaching for a global source of randomness. That's what makes engine.dart
// unit-testable with a seeded, deterministic `Random(seed)` — something the
// JS version, built entirely on the global `Math.random()`, never had.

import 'dart:math';

int rollD100(Random rng) => rng.nextInt(100) + 1;

/// Fisher-Yates, non-mutating.
List<T> shuffle<T>(List<T> array, Random rng) {
  final result = List<T>.from(array);
  for (var i = result.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = result[i];
    result[i] = result[j];
    result[j] = tmp;
  }
  return result;
}

/// A value in [0,1), skewed by `power`: power > 1 pulls toward 0, power < 1
/// pulls toward 1, power == 1 is a plain uniform roll. Standard inverse-power
/// trick for cheaply shaping a distribution without a full Beta/Gamma sampler.
double skewedRandom01(double power, Random rng) => pow(rng.nextDouble(), power).toDouble();
