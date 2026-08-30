// Ported from screens.js's renderCredits.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_screen_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/nav_button.dart';
import '../widgets/nav_row.dart';

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appController = ref.read(appScreenControllerProvider.notifier);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Credits', style: AppTheme.cardHeading),
          const SizedBox(height: 16),
          const Text('Designed and built by Pocket Badger Studios.', style: AppTheme.eventText),
          NavRow(leading: [NavButton(label: 'Back', onPressed: appController.showMenu)]),
        ],
      ),
    );
  }
}
