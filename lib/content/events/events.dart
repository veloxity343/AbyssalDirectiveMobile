// Aggregates every event category into one list. This folder is split by
// mechanical role, not by story — add a new event to whichever file matches
// what it DOES:
//   standalone_events.dart      — one-off flavor/hazard scenarios, no special tag
//   site_discovery_events.dart  — isSiteDiscovery: true, not gated behind another event
//   gamble_events.dart          — gamble: true choices
//   sacrifice_events.dart       — built around a crewDelta-losing choice
//   chain_events.dart           — multi-step, gated behind flags set by an earlier step
// Combined with once-only events and cycle-gated requirements, no single run
// sees the full list below.
//
// Ported 1:1 from the web prototype's src/content/events/index.js.

import 'event_schema.dart';
import 'standalone_events.dart';
import 'site_discovery_events.dart';
import 'gamble_events.dart';
import 'sacrifice_events.dart';
import 'chain_events.dart';

final List<GameEvent> events = [
  ...standaloneEvents,
  ...siteDiscoveryEvents,
  ...gambleEvents,
  ...sacrificeEvents,
  ...chainEvents,
];
