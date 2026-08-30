// Ported from screens.js's renderMenu.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_providers.dart';
import '../state/app_screen_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/choice_button.dart';
import '../widgets/confirm_inline.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    final hasSave = ref.watch(hasSaveProvider).valueOrNull ?? false;
    final appController = ref.read(appScreenControllerProvider.notifier);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('THE ABYSSAL DIRECTIVE', style: AppTheme.title, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                'You are the last word spoken before the pressure speaks instead.',
                style: AppTheme.subtitle,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 320,
              child: Column(
                children: [
                  ChoiceButton(
                    label: 'New Game',
                    onPressed: () {
                      if (hasSave && !_confirming) {
                        setState(() => _confirming = true);
                      } else if (!hasSave) {
                        appController.startIntro();
                      }
                    },
                  ),
                  if (_confirming)
                    ConfirmInline(
                      text: "Your last directive is already in progress.\n"
                          "The Company does not look kindly on wasted expenditure.\n"
                          "Are you certain you wish abandon your last expedition and start a new one?",
                      onConfirm: appController.startIntro,
                      onCancel: () => setState(() => _confirming = false),
                    ),
                  ChoiceButton(
                    label: 'Continue Game',
                    onPressed: hasSave ? appController.continueGame : null,
                  ),
                  ChoiceButton(label: 'Mission History', onPressed: appController.showHistory),
                  ChoiceButton(label: 'Credits', onPressed: appController.showCredits),
                  ChoiceButton(label: 'Privacy Policy', onPressed: appController.showPrivacy),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
