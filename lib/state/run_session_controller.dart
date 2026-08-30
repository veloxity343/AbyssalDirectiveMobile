// The Flutter/Riverpod replacement for game.js's startGame() closure. The
// biggest structural difference from the JS version: there, one `state`
// object plus a handful of closure variables drove a manual
// `app.innerHTML = ...` re-render on every mutation. Here, every mutation
// produces a new immutable RunSessionState that Riverpod diffs and rebuilds
// widgets from — so there's no render()/persist()-everywhere dance, just
// state assignment. `_advance()` is the direct port of JS's `render()`:
// same branching, same order, same siteCountdown/pendingSiteDiscovery
// bookkeeping, just async (SharedPreferences, unlike localStorage, is
// inherently async) and returning a screen value instead of mutating the
// DOM.
//
// Diff-badge bookkeeping (prevHabitatStats/prevCrew/prevDrones/
// prevSiteStats in the JS version) is deliberately NOT here — that was only
// needed because the JS version manually re-rendered and had to diff
// against what it last painted. In Flutter, StatBar widgets do that
// comparison themselves in didUpdateWidget, which is simpler and doesn't
// need to live in session state at all (see widgets/stat_bar.dart).

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/events/event_schema.dart';
import '../content/events/events.dart' as events_content;
import '../content/stats.dart' as stats_content;
import '../engine/engine.dart';
import '../engine/game_state.dart';
import '../services/storage_providers.dart';
import '../services/storage_service.dart';
import 'run_screen.dart';
import 'run_session_state.dart';

class RunSessionController extends StateNotifier<RunSessionState> {
  final StorageService _storage;
  Random _rng = Random();
  GameEvent? _currentEvent;
  bool _pendingPowerOn = false;
  SiteInstance? _pendingSiteDiscovery;

  RunSessionController(this._storage) : super(const RunSessionState(screen: IdleRunScreen()));

  Future<void> startNewGame(int directiveNumber) async {
    _rng = Random();
    _currentEvent = null;
    _pendingSiteDiscovery = null;
    _pendingPowerOn = true;
    await _storage.clearSave();
    state = RunSessionState(
      gameState: createInitialState(_rng, directiveNumber: directiveNumber),
      screen: const IdleRunScreen(),
    );
    await _advance();
  }

  /// Returns false (and leaves state untouched) if there's no save to
  /// resume — the caller should have checked StorageService.hasSave first,
  /// but this stays safe either way.
  Future<bool> resumeGame() async {
    final loaded = await _storage.loadGame();
    if (loaded == null) return false;

    _rng = Random();
    _pendingPowerOn = false;
    _pendingSiteDiscovery = null;
    GameEvent? currentEvent;
    if (loaded.currentEventId != null) {
      for (final e in events_content.events) {
        if (e.id == loaded.currentEventId) {
          currentEvent = e;
          break;
        }
      }
    }
    _currentEvent = currentEvent;
    state = RunSessionState(gameState: loaded.state, screen: const IdleRunScreen());
    await _advance();
    return true;
  }

  Future<void> resolveChoiceAction(GameEvent event, Choice choice) async {
    final gs = state.gameState!;
    final result = resolveChoice(gs, event, choice, _rng);
    _currentEvent = null;
    _pendingSiteDiscovery = result.discoveredSite;
    await _persist();
    state = RunSessionState(
      gameState: gs,
      screen: OutcomeRunScreen(text: result.text, succeeded: result.succeeded),
    );
  }

  Future<void> continueFromOutcome() => _advance();

  /// "Not Yet" on a site scenario — always lands on a plain scenario next
  /// rather than risking back-to-back site offers.
  Future<void> declineSite() => _advance(skipSiteCheck: true);

  Future<void> exploreAnomalyAction(SiteInstance site, String anomalyId) async {
    exploreSiteAnomaly(state.gameState!, site, anomalyId, _rng);
    await _persist();
    state = RunSessionState(
      gameState: state.gameState,
      screen: SiteRunScreen(site: site, isNewDiscovery: false),
    );
  }

  Future<void> settleAction(SiteInstance site) async {
    final result = settleAtSite(state.gameState!, site, _rng);
    await _finishRun(result.title, result.paragraphs);
  }

  Future<void> _persist() => _storage.saveGame(state.gameState!, _currentEvent?.id);

  Future<void> _finishRun(String title, List<String> narrativeParagraphs) async {
    final gs = state.gameState!;
    await _storage.clearSave();
    await _storage.addHistoryEntry(HistoryEntry(
      title: title,
      cyclesSurvived: gs.cycle - 1,
      crewSurvived: gs.crewCount,
      sitesDiscovered: gs.sites.map((s) => s.name).toList(),
      date: DateTime.now().toUtc().toIso8601String(),
    ));
    final sitesNote =
        gs.sites.isNotEmpty ? ' Sites charted: ${gs.sites.map((s) => s.name).join(", ")}.' : '';
    final tally =
        'Survived ${gs.cycle - 1} cycles. ${gs.crewCount} of ${stats_content.startingCrew} crew remaining.$sitesNote';
    state = RunSessionState(
      gameState: gs,
      screen: EndingRunScreen(title: title, paragraphs: [...narrativeParagraphs, tally]),
    );
  }

  /// Direct port of game.js's render(). `skipSiteCheck` is used by
  /// declineSite() so declining a site offer always lands on a plain
  /// scenario next.
  Future<void> _advance({bool skipSiteCheck = false}) async {
    final gs = state.gameState!;
    final ending = checkEnding(gs);
    if (ending != null) {
      await _finishRun(ending.title, [ending.text]);
      return;
    }

    if (!skipSiteCheck && _pendingSiteDiscovery != null) {
      final site = _pendingSiteDiscovery!;
      _pendingSiteDiscovery = null;
      gs.siteCountdown = randomSiteInterval(_rng);
      state = RunSessionState(gameState: gs, screen: SiteRunScreen(site: site, isNewDiscovery: true));
      return;
    }

    // Guarantees a site-related scenario within 1-3 plain scenarios, rather
    // than leaving it to weighted luck across the whole event pool. Resets
    // the countdown as soon as it's acted on, whether or not a new
    // discovery event was actually available — the guarantee is an
    // *opportunity* every so often, not that the player commits to it.
    if (!skipSiteCheck && _currentEvent == null && gs.siteCountdown <= 0) {
      gs.siteCountdown = randomSiteInterval(_rng);
      final forcedEvent = drawSiteDiscoveryEvent(gs, _rng);
      if (forcedEvent != null) {
        _currentEvent = forcedEvent;
        await _persist();
        _showEvent(forcedEvent);
        return;
      }
      if (gs.sites.isNotEmpty) {
        final site = gs.sites[_rng.nextInt(gs.sites.length)];
        state = RunSessionState(gameState: gs, screen: SiteRunScreen(site: site, isNewDiscovery: false));
        return;
      }
      // Nothing available yet this early — fall through to a normal scenario.
    }

    _currentEvent ??= drawEvent(gs, _rng);
    if (_currentEvent == null) {
      gs.cycle += 1;
      await _advance(skipSiteCheck: true);
      return;
    }
    await _persist();
    _showEvent(_currentEvent!);
  }

  void _showEvent(GameEvent event) {
    final powerOn = _pendingPowerOn;
    _pendingPowerOn = false;
    state = RunSessionState(gameState: state.gameState, screen: EventRunScreen(event: event, powerOn: powerOn));
  }
}

final runSessionControllerProvider = StateNotifierProvider<RunSessionController, RunSessionState>((ref) {
  return RunSessionController(ref.watch(storageServiceProvider));
});
