// Ported from screens.js's renderIntro/buildIntroLines. Unlike the ending
// screen, this REPLACES the visible line each step rather than
// accumulating them — AnimatedSwitcher (with reverseDuration: 0) mirrors
// that: the old line disappears instantly, the new one fades in, matching
// style.css's .line-in used one line at a time here.
//
// Note: the web version's paper.jpg background photo isn't available in
// this environment (never read into the session), so this uses a flat
// paper-toned color instead — see app_theme.dart's header for the follow-up.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_screen_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/choice_button.dart';
import '../widgets/nav_button.dart';
import '../widgets/nav_row.dart';

class _IntroLine {
  final String text;
  final bool status;
  const _IntroLine(this.text, {this.status = false});
}

List<_IntroLine> _buildIntroLines(int directiveNumber) => [
      const _IntroLine('DIRECTIVE STATUS: ACTIVE', status: true),
      _IntroLine(
        'Three hundred meters down, past the point where sunlight is a rumour, Habitat Directive $directiveNumber clings to the trench wall.',
      ),
      const _IntroLine("Its lease runs out far sooner than the hull will."),
      const _IntroLine(
        "You are Employee #11061910, its current director, and the only role on board who answers to the surface.",
      ),
      const _IntroLine("The Corporation wants data. Not headlines."),
      const _IntroLine("They will not send help unless the paperwork favours it."),
      const _IntroLine("Hull. Air. People. Supplies. Your own standing above the waves."),
      const _IntroLine(
        "Every gauge down here only moves one way, unless you spend something else to move it back.",
      ),
      const _IntroLine("There are no clean choices. Your job is not to win. It's to last."),
      const _IntroLine(
        "The trench isn't empty. Keep looking, and you'll chart other footholds out there, some worse than this, a few maybe better.",
      ),
      const _IntroLine("You don't have to wait for the hull or the ocean to decide when this ends."),
      const _IntroLine(
        "Whenever you find somewhere worth staying, the choice is yours to make. Not corporate's. Not the depth's.",
      ),
    ];

class IntroScreen extends ConsumerStatefulWidget {
  final int directiveNumber;

  const IntroScreen({super.key, required this.directiveNumber});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  int _index = 0;
  late final List<_IntroLine> _lines = _buildIntroLines(widget.directiveNumber);

  @override
  Widget build(BuildContext context) {
    final line = _lines[_index];
    final isDone = _index >= _lines.length - 1;
    final appController = ref.read(appScreenControllerProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFC9B896), // approximate parchment tone
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Color(0x8C000000), blurRadius: 26, offset: Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.paperHeading.withOpacity(0.25))),
            ),
            child: Text(
              'Habitat Directive ${widget.directiveNumber}',
              style: const TextStyle(color: AppColors.paperHeading, fontSize: 20.8, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${_index + 1} / ${_lines.length}',
            style: TextStyle(color: AppColors.paperHeading.withOpacity(0.85), fontSize: 12, letterSpacing: 1.2, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            reverseDuration: Duration.zero,
            child: line.status
                ? Transform.rotate(
                    key: ValueKey(_index),
                    angle: -0.035,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.paperStatusBorder)),
                      child: Text(
                        line.text,
                        style: const TextStyle(
                          color: AppColors.paperStatusText,
                          fontSize: 12.8,
                          letterSpacing: 1.9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Text(
                    line.text,
                    key: ValueKey(_index),
                    style: const TextStyle(color: AppColors.paperInk, fontSize: 16.8, height: 1.6, fontFamily: 'monospace'),
                  ),
          ),
          if (isDone) ...[
            const SizedBox(height: 24),
            ChoiceButton(label: 'Descend', onPressed: () => appController.beginRun(widget.directiveNumber)),
          ],
          NavRow(
            leading: [
              if (!isDone) NavButton(label: 'Continue', onPressed: () => setState(() => _index += 1)),
              NavButton(label: 'Back', onPressed: appController.showMenu),
            ],
            trailing: isDone ? null : NavButton(label: 'Skip', onPressed: () => setState(() => _index = _lines.length - 1)),
          ),
        ],
      ),
    );
  }
}
