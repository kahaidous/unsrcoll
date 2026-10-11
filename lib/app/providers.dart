import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';
import '../domain/app_state.dart';
import '../platform/capabilities.dart';

final appStoreProvider = Provider<AppStore>(
  (ref) => throw StateError('AppStore must be provided at app startup.'),
);
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final platformInterventionServiceProvider =
    Provider<PlatformInterventionService>(
      (ref) => const ManualOnlyInterventionService(),
    );
final platformCapabilitiesProvider = FutureProvider<CapabilitySnapshot>(
  (ref) => ref.watch(platformInterventionServiceProvider).getCapabilities(),
);
final appStateProvider = NotifierProvider<AppStateController, AppState>(
  AppStateController.new,
);

class AppStateController extends Notifier<AppState> {
  late AppStore _store;
  late DateTime Function() _now;

  @override
  AppState build() {
    _store = ref.watch(appStoreProvider);
    _now = ref.watch(clockProvider);
    final loaded = _store.load();
    final active = loaded.activeSession;
    if (active != null && !active.endsAt.isAfter(_now())) {
      final finished = active.finish(at: active.endsAt, completed: true);
      final recovered = loaded.copyWith(
        sessions: [
          for (final session in loaded.sessions)
            if (session.id == active.id) finished else session,
        ],
      );
      unawaited(_store.save(recovered));
      return recovered;
    }
    return loaded;
  }

  Future<void> savePreferences(AppPreferences preferences) async {
    await _commit(state.copyWith(preferences: preferences));
  }

  Future<void> startFocus({required int minutes}) async {
    if (minutes < 1 || state.activeSession != null) return;
    final now = _now().toUtc();
    final session = FocusSession(
      id: now.microsecondsSinceEpoch.toString(),
      startedAt: now,
      endsAt: now.add(Duration(minutes: minutes)),
      intention: state.preferences.intention,
    );
    await _commit(state.copyWith(sessions: [...state.sessions, session]));
  }

  Future<void> finishFocus({bool early = false}) async {
    final active = state.activeSession;
    if (active == null) return;
    final now = _now().toUtc();
    final finished = active.finish(
      at: early ? now : active.endsAt,
      completed: !early,
    );
    await _commit(
      state.copyWith(
        sessions: [
          for (final session in state.sessions)
            if (session.id == active.id) finished else session,
        ],
      ),
    );
  }

  Future<void> refreshFocus() async {
    final active = state.activeSession;
    if (active != null && !_now().toUtc().isBefore(active.endsAt)) {
      await finishFocus();
    }
  }

  Future<void> addReflection({
    required int focusRating,
    required int energyRating,
    String note = '',
  }) async {
    final now = _now().toUtc();
    final entry = ReflectionEntry(
      id: now.microsecondsSinceEpoch.toString(),
      createdAt: now,
      focusRating: focusRating,
      energyRating: energyRating,
      note: note.trim(),
    );
    await _commit(state.copyWith(reflections: [entry, ...state.reflections]));
  }

  Future<void> deleteReflection(String id) async {
    await _commit(
      state.copyWith(
        reflections: state.reflections
            .where((entry) => entry.id != id)
            .toList(),
      ),
    );
  }

  Future<void> eraseAllData() async {
    await _store.clear();
    state = const AppState();
  }

  Future<void> _commit(AppState next) async {
    state = next;
    await _store.save(next);
  }
}
