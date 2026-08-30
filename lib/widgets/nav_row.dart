// Ported from style.css's .nav-row + #skip-btn. `trailing` (Skip, on the
// intro and ending screens) is pushed to the far right, apart from the
// leading buttons (Continue, and Back on the intro) — mirrors the web
// version's `margin-left: auto` trick.
import 'package:flutter/widgets.dart';

class NavRow extends StatelessWidget {
  final List<Widget> leading;
  final Widget? trailing;

  const NavRow({super.key, required this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Wrap(spacing: 10, runSpacing: 10, children: leading),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}
