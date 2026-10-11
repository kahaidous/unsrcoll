import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intentional_phone_use_coach/app/providers.dart';
import 'package:intentional_phone_use_coach/data/local_store.dart';
import 'package:intentional_phone_use_coach/domain/app_state.dart';

class MemoryStore implements AppStore {
  MemoryStore([this.state = const AppState()]);
  AppState state;

  @override
  AppState load() => state;

  @override
  Future<void> save(AppState next) async => state = next;

  @override
  Future<void> clear() async => state = const AppState();

  @override
  String exportJson(AppState state) => state.toJson().toString();
}

void main() {
  final fixedNow = DateTime.utc(2026, 10, 11, 11, 30);

  ProviderContainer makeContainer(MemoryStore store, DateTime Function() now) {
    return ProviderContainer(
      overrides: [
        appStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(now),
      ],
    );
  }

  test(
    'focus session is persisted and can end early without a failure label',
    () async {
      final store = MemoryStore();
      final container = makeContainer(store, () => fixedNow);
      addTearDown(container.dispose);

      await container.read(appStateProvider.notifier).startFocus(minutes: 25);
      final active = container.read(appStateProvider).activeSession;
      expect(active, isNotNull);
      expect(active!.endsAt, fixedNow.add(const Duration(minutes: 25)));
      expect(store.state.sessions, hasLength(1));

      await container.read(appStateProvider.notifier).finishFocus(early: true);
      final ended = container.read(appStateProvider).sessions.single;
      expect(ended.isActive, isFalse);
      expect(ended.completed, isFalse);
      expect(ended.endedAt, fixedNow);
    },
  );

  test('an expired active timer recovers as a completed session', () {
    final started = fixedNow.subtract(const Duration(minutes: 30));
    final session = FocusSession(
      id: 'old-session',
      startedAt: started,
      endsAt: started.add(const Duration(minutes: 25)),
      intention: IntentionCategory.study,
    );
    final store = MemoryStore(AppState(sessions: [session]));
    final container = makeContainer(store, () => fixedNow);
    addTearDown(container.dispose);

    final recovered = container.read(appStateProvider);
    expect(recovered.activeSession, isNull);
    expect(recovered.sessions.single.completed, isTrue);
  });

  test('reflection entries round trip and are removable', () async {
    final store = MemoryStore();
    final container = makeContainer(store, () => fixedNow);
    addTearDown(container.dispose);

    await container
        .read(appStateProvider.notifier)
        .addReflection(
          focusRating: 4,
          energyRating: 2,
          note: '  Took a short walk.  ',
        );
    final saved = store.state.reflections.single;
    expect(saved.note, 'Took a short walk.');
    expect(saved.focusRating, 4);
    expect(
      AppState.fromJson(store.state.toJson()).reflections.single.note,
      saved.note,
    );

    await container.read(appStateProvider.notifier).deleteReflection(saved.id);
    expect(container.read(appStateProvider).reflections, isEmpty);
  });

  test('erase all clears local records and resets onboarding', () async {
    final store = MemoryStore(
      AppState(
        preferences: const AppPreferences(
          onboardingComplete: true,
          weeklyFocusGoal: 3,
        ),
        reflections: [
          ReflectionEntry(
            id: 'reflection',
            createdAt: fixedNow,
            focusRating: 3,
            energyRating: 4,
          ),
        ],
      ),
    );
    final container = makeContainer(store, () => fixedNow);
    addTearDown(container.dispose);

    await container.read(appStateProvider.notifier).eraseAllData();

    expect(
      container.read(appStateProvider).preferences.onboardingComplete,
      isFalse,
    );
    expect(container.read(appStateProvider).sessions, isEmpty);
    expect(container.read(appStateProvider).reflections, isEmpty);
    expect(store.state.reflections, isEmpty);
  });
}
