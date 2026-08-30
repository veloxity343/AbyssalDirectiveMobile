// A candidate site's own geological/oceanic stats — a different axis set
// entirely from the habitat's (see site_stats.dart), so the player can weigh
// what the SITE offers on its own terms before committing to it. Flickers
// on every time the site is visited (unlike HabitatStatsBar, which only
// powers on once at the start of a fresh run) — reading a site's survey
// data is framed as its own small event each time. Ported from game.js's
// renderSiteStatsBar.
import 'package:flutter/widgets.dart';

import '../content/site_stats.dart' as site_stats_content;
import '../engine/game_state.dart';
import 'stat_row.dart';

const _flickerStep = Duration(milliseconds: 200);
const _flickerStart = Duration(milliseconds: 50);

class SiteStatsBar extends StatelessWidget {
  final SiteInstance site;

  const SiteStatsBar({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    final order = List<int>.generate(site_stats_content.siteStats.length, (i) => i)..shuffle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < site_stats_content.siteStats.length; i++)
          StatRow(
            label: site_stats_content.siteStats[i].label,
            value: site.stats[site_stats_content.siteStats[i].id] ?? 0,
            powerOnDelay: _flickerStart + _flickerStep * order.indexOf(i),
          ),
      ],
    );
  }
}
