// All persistence is local-only, mirroring storage.js's exact API and
// behavior: a single in-progress save and a rolling history of past runs.
// One unavoidable shape difference from the JS version: `SharedPreferences`
// is inherently async (unlike synchronous `localStorage`), so every method
// here returns a Future where its JS counterpart didn't. Every call is still
// wrapped in try/catch — local storage can fail (permissions, corruption)
// and that should never crash the game, exactly as the original comment
// says.
//
// Note: the JS version also back-fills several fields for saves that
// predate features shipped mid-development (missing `drones`,
// `siteCountdown`, per-site geology stats, etc.) — that migration path isn't
// ported here, since this app starts with zero legacy local saves to
// migrate from. GameState.fromJson expects a save produced by this app's own
// GameState.toJson.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/game_state.dart';

class HistoryEntry {
  final String title;
  final int cyclesSurvived;
  final int crewSurvived;
  final List<String> sitesDiscovered;
  final String date; // ISO-8601, matches DateTime.now().toUtc().toIso8601String()

  HistoryEntry({
    required this.title,
    required this.cyclesSurvived,
    required this.crewSurvived,
    required this.sitesDiscovered,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'cyclesSurvived': cyclesSurvived,
        'crewSurvived': crewSurvived,
        'sitesDiscovered': sitesDiscovered,
        'date': date,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        title: json['title'] as String,
        cyclesSurvived: json['cyclesSurvived'] as int,
        crewSurvived: json['crewSurvived'] as int,
        sitesDiscovered: List<String>.from(json['sitesDiscovered'] as List? ?? const []),
        date: json['date'] as String,
      );
}

class StorageService {
  static const _saveKey = 'abyssal_directive_save';
  static const _historyKey = 'abyssal_directive_history';
  static const _historyLimit = 50;

  Future<void> saveGame(GameState state, String? currentEventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {'state': state.toJson(), 'currentEventId': currentEventId};
      await prefs.setString(_saveKey, jsonEncode(payload));
    } catch (_) {
      // ignore, progress just won't persist this session
    }
  }

  Future<({GameState state, String? currentEventId})?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_saveKey);
      if (raw == null) return null;
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final state = GameState.fromJson(parsed['state'] as Map<String, dynamic>);
      return (state: state, currentEventId: parsed['currentEventId'] as String?);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_saveKey);
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
    } catch (_) {
      // ignore
    }
  }

  Future<void> addHistoryEntry(HistoryEntry entry) async {
    try {
      final history = await getHistory();
      history.insert(0, entry);
      final trimmed = history.take(_historyLimit).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
    } catch (_) {
      // ignore
    }
  }

  Future<List<HistoryEntry>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
