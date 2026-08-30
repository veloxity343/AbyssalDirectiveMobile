// Top-level navigation — the Flutter/Riverpod replacement for main.js's
// showMenu/showIntro/showHistory/showCredits/showPrivacy router. Deliberately
// a plain state switcher rather than Flutter's Navigator/named routes: this
// app has no deep linking or URL-driven navigation to support, and the JS
// original didn't need one either — a sealed class plus a StateNotifier is
// the direct equivalent of "one function shows one screen."

sealed class AppScreen {
  const AppScreen();
}

class MenuAppScreen extends AppScreen {
  const MenuAppScreen();
}

/// Generated once per new-game attempt (not per intro page) so the number
/// shown throughout the intro matches the one the actual run gets saved
/// under — see AppScreenController.startIntro.
class IntroAppScreen extends AppScreen {
  final int directiveNumber;
  const IntroAppScreen(this.directiveNumber);
}

class HistoryAppScreen extends AppScreen {
  const HistoryAppScreen();
}

class CreditsAppScreen extends AppScreen {
  const CreditsAppScreen();
}

class PrivacyAppScreen extends AppScreen {
  const PrivacyAppScreen();
}

/// The actual gameplay loop's content is driven by RunSessionController,
/// not this screen's own data — this just marks that it's on screen.
class GameAppScreen extends AppScreen {
  const GameAppScreen();
}
