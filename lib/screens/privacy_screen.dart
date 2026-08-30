// Adapted (not a literal port) from screens.js's renderPrivacy — the web
// version's wording is web-specific ("localStorage", "clearing your site
// data") and doesn't carry over to a mobile app. This keeps the same
// substance for what's true *right now*: no backend is wired up yet, so
// there's genuinely no data collection or network activity.
//
// IMPORTANT: once the Supabase/AdMob/RevenueCat monetization phase lands
// (anonymous auth, ad SSV, purchase receipts), this text will become
// factually wrong and MUST be rewritten to disclose what's actually
// collected and why — don't ship this copy unchanged past that point.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_screen_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/nav_button.dart';
import '../widgets/nav_row.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appController = ref.read(appScreenControllerProvider.notifier);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Privacy Policy', style: AppTheme.cardHeading),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'The Abyssal Directive does not collect, store, or transmit any data about you or '
              'your device. There is no analytics, no tracking, no account, and no network request '
              'made by this app.',
              style: AppTheme.eventText,
            ),
          ),
          const Text(
            'Your save and mission history are kept only in local storage on your own device. '
            'That data never leaves your device, is never sent to anyone, and can be erased at '
            'any time by clearing this app\'s data or uninstalling it.',
            style: AppTheme.eventText,
          ),
          NavRow(leading: [NavButton(label: 'Back', onPressed: appController.showMenu)]),
        ],
      ),
    );
  }
}
