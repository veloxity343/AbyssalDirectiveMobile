// The habitat's own condition: crew count, its 5 stat gauges, then the
// recon drone count. Ported from game.js's renderHabitatStatsBar. Diff
// badges just fall out of StatRow/CountRow rebuilding with a new `value`
// each time gameState changes — no snapshot-tracking needed here.
import 'package:flutter/widgets.dart';

import '../content/stats.dart' as stats_content;
import '../engine/game_state.dart';
import 'count_row.dart';
import 'stat_row.dart';

const _flickerStep = Duration(milliseconds: 200);
const _flickerStart = Duration(milliseconds: 50);

class HabitatStatsBar extends StatelessWidget {
  final GameState gameState;
  /// True only on a fresh run's first screen — staggers each row's
  /// power-on flicker-in, in a shuffled order so it's not identical every
  /// time (see game.js's shuffle() usage).
  final bool powerOn;

  const HabitatStatsBar({super.key, required this.gameState, required this.powerOn});

  @override
  Widget build(BuildContext context) {
    final order = List<int>.generate(stats_content.stats.length, (i) => i);
    if (powerOn) order.shuffle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountRow(label: stats_content.crewDisplay.label, value: gameState.crewCount),
        for (var i = 0; i < stats_content.stats.length; i++)
          StatRow(
            label: stats_content.stats[i].label,
            value: gameState.stats[stats_content.stats[i].id] ?? 0,
            powerOnDelay: powerOn ? _flickerStart + _flickerStep * order.indexOf(i) : null,
          ),
        CountRow(label: stats_content.droneDisplay.label, value: gameState.drones),
      ],
    );
  }
}
