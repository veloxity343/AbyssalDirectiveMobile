import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

/// Watched by the main menu to enable/disable "Continue Game" and to decide
/// whether "New Game" needs the are-you-sure confirmation.
final hasSaveProvider = FutureProvider<bool>((ref) => ref.watch(storageServiceProvider).hasSave());

/// Watched by the history screen.
final historyProvider = FutureProvider<List<HistoryEntry>>((ref) => ref.watch(storageServiceProvider).getHistory());
