// Entry point — ported from main.js, minus the routing logic itself (that's
// AppScreenController now). ProviderScope is Riverpod's equivalent of
// wrapping the app in a context that all the StateNotifierProviders read
// from.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}
