import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/engine.dart' show generateDirectiveNumber;
import 'app_screen.dart';
import 'run_session_controller.dart';

class AppScreenController extends StateNotifier<AppScreen> {
  final Ref _ref;

  AppScreenController(this._ref) : super(const MenuAppScreen());

  void showMenu() => state = const MenuAppScreen();

  /// Rolled once per new-game attempt (not per intro page, and independent
  /// of the game session's own RNG, which doesn't exist yet at this point)
  /// so the number shown throughout the intro matches the one the actual
  /// run gets saved under once beginRun() starts it.
  void startIntro() {
    state = IntroAppScreen(generateDirectiveNumber(Random()));
  }

  Future<void> beginRun(int directiveNumber) async {
    await _ref.read(runSessionControllerProvider.notifier).startNewGame(directiveNumber);
    state = const GameAppScreen();
  }

  Future<void> continueGame() async {
    final resumed = await _ref.read(runSessionControllerProvider.notifier).resumeGame();
    if (resumed) state = const GameAppScreen();
  }

  void showHistory() => state = const HistoryAppScreen();
  void showCredits() => state = const CreditsAppScreen();
  void showPrivacy() => state = const PrivacyAppScreen();
}

final appScreenControllerProvider = StateNotifierProvider<AppScreenController, AppScreen>((ref) {
  return AppScreenController(ref);
});
