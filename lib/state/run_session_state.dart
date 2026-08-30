import '../engine/game_state.dart';
import 'run_screen.dart';

/// `gameState` is null only in the IdleRunScreen state, before startNewGame
/// or resumeGame has been called.
class RunSessionState {
  final GameState? gameState;
  final RunScreen screen;
  const RunSessionState({this.gameState, required this.screen});
}
