// Ported from game.js's renderEnding. Paragraphs accumulate (unlike the
// intro's replace-one-line approach) — Continue reveals one more, Skip
// reveals the rest at once, and the tally is always the final paragraph
// (already appended by RunSessionController._finishRun), styled apart from
// the narrative ones. Each paragraph fades in once, the first time it's
// built — since the list only ever grows and nothing is keyed/reordered,
// Flutter's default positional widget diffing means only the newest one is
// ever actually "new" on a given rebuild, so this needs no manual
// "which one is newest" bookkeeping.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_screen_controller.dart';
import '../state/run_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/choice_button.dart';
import '../widgets/nav_button.dart';
import '../widgets/nav_row.dart';

class EndingScreenView extends ConsumerStatefulWidget {
  final EndingRunScreen screen;

  const EndingScreenView({super.key, required this.screen});

  @override
  ConsumerState<EndingScreenView> createState() => _EndingScreenViewState();
}

class _EndingScreenViewState extends ConsumerState<EndingScreenView> {
  int _revealed = 1;

  @override
  Widget build(BuildContext context) {
    final paragraphs = widget.screen.paragraphs;
    final isDone = _revealed >= paragraphs.length;
    final appController = ref.read(appScreenControllerProvider.notifier);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.screen.title,
            style: const TextStyle(color: AppColors.warn, fontSize: 25.6, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _revealed; i++)
            _FadeInOnce(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  paragraphs[i],
                  style: i == paragraphs.length - 1 ? AppTheme.meta : AppTheme.eventText,
                ),
              ),
            ),
          if (isDone)
            ChoiceButton(label: 'Return to Main Menu', onPressed: appController.showMenu)
          else
            NavRow(
              leading: [NavButton(label: 'Continue', onPressed: () => setState(() => _revealed += 1))],
              trailing: NavButton(label: 'Skip', onPressed: () => setState(() => _revealed = paragraphs.length)),
            ),
        ],
      ),
    );
  }
}

class _FadeInOnce extends StatefulWidget {
  final Widget child;
  const _FadeInOnce({required this.child});

  @override
  State<_FadeInOnce> createState() => _FadeInOnceState();
}

class _FadeInOnceState extends State<_FadeInOnce> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _controller, child: widget.child);
}
