// Ported from screens.js's renderHistory.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_providers.dart';
import '../services/storage_service.dart';
import '../state/app_screen_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/nav_button.dart';
import '../widgets/nav_row.dart';

String _formatDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  final local = date.toLocal();
  return '${local.month}/${local.day}/${local.year}';
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider).valueOrNull ?? const <HistoryEntry>[];
    final appController = ref.read(appScreenControllerProvider.notifier);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Mission History', style: AppTheme.cardHeading),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Text('No missions logged yet. The trench is still waiting.', style: AppTheme.eventText)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final h in history) _HistoryRow(entry: h)],
            ),
          NavRow(leading: [NavButton(label: 'Back', onPressed: appController.showMenu)]),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;

  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cycles = entry.cyclesSurvived;
    final cycleLabel = '$cycles cycle${cycles == 1 ? '' : 's'}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(child: Text(entry.title, style: AppTheme.eventText.copyWith(fontSize: 15))),
              Text(
                '$cycleLabel · ${_formatDate(entry.date)}',
                style: AppTheme.meta.copyWith(fontSize: 12.8),
              ),
            ],
          ),
          Text('${entry.crewSurvived} crew remaining', style: AppTheme.meta.copyWith(fontSize: 12.5)),
          if (entry.sitesDiscovered.isNotEmpty)
            Text('Sites charted: ${entry.sitesDiscovered.join(", ")}', style: AppTheme.meta.copyWith(fontSize: 12.5)),
        ],
      ),
    );
  }
}
