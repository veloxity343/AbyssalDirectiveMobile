// A site's incidental features (see content/anomalies.dart). Each starts as
// a detected-but-unidentified entry — label + sensor-only blurb, plus a
// button to spend a drone finding out what it actually is. Once explored,
// it's replaced by its revealed nature and blurb for good; whatever it
// nudged is already folded into SiteStatsBar above. Ported from game.js's
// renderAnomalies.
import 'package:flutter/material.dart';

import '../content/anomalies.dart' as anomalies_content;
import '../engine/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AnomalyList extends StatelessWidget {
  final SiteInstance site;
  final int drones;
  final void Function(String anomalyId) onExplore;

  const AnomalyList({super.key, required this.site, required this.drones, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final entries = <(AnomalyInstance, anomalies_content.Anomaly)>[];
    for (final instance in site.anomalies) {
      anomalies_content.Anomaly? def;
      for (final a in anomalies_content.anomalies) {
        if (a.id == instance.id) {
          def = a;
          break;
        }
      }
      if (def != null) entries.add((instance, def));
    }
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final (instance, def) in entries) _AnomalyTile(instance: instance, def: def, drones: drones, onExplore: onExplore)],
      ),
    );
  }
}

class _AnomalyTile extends StatelessWidget {
  final AnomalyInstance instance;
  final anomalies_content.Anomaly def;
  final int drones;
  final void Function(String anomalyId) onExplore;

  const _AnomalyTile({required this.instance, required this.def, required this.drones, required this.onExplore});

  Color get _borderColor {
    if (!instance.explored) return AppColors.line;
    switch (instance.nature) {
      case "positive":
        return AppColors.accent;
      case "negative":
        return AppColors.danger;
      default:
        return AppColors.line;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 11),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: _borderColor, width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: AppTheme.meta.copyWith(fontSize: 14.4, height: 1.5),
              children: [
                TextSpan(text: '${def.label}. ', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                TextSpan(text: instance.explored ? instance.blurb : def.detectedBlurb),
              ],
            ),
          ),
          if (!instance.explored) ...[
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: drones > 0 ? () => onExplore(def.id) : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDim,
                side: const BorderSide(color: AppColors.line),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                textStyle: const TextStyle(fontSize: 12.8),
              ),
              child: const Text('Explore (1 Drone)'),
            ),
          ],
        ],
      ),
    );
  }
}
