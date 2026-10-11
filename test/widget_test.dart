import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intentional_phone_use_coach/app/app.dart';
import 'package:intentional_phone_use_coach/app/providers.dart';
import 'package:intentional_phone_use_coach/data/local_store.dart';
import 'package:intentional_phone_use_coach/domain/app_state.dart';
import 'package:intentional_phone_use_coach/l10n/copy.dart';

class _MemoryStore implements AppStore {
  AppState state = const AppState();
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
  testWidgets('user can skip setup and reach the manual-mode dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStoreProvider.overrideWithValue(_MemoryStore())],
        child: const StillwellApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(Copy.welcomeTitle), findsOneWidget);
    await tester.tap(find.text(Copy.skipSetup));
    await tester.pumpAndSettle();

    expect(find.text(Copy.startFocus), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(Copy.usageUnavailable),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(Copy.usageUnavailable), findsOneWidget);
  });

  testWidgets('focus timer starts and can end early without an OS blocker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStoreProvider.overrideWithValue(_MemoryStore())],
        child: const StillwellApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.skipSetup));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.startFocus));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.durationLabel(10)));
    await tester.pump();
    await tester.tap(find.text(Copy.beginFocus));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(Copy.timerDisclaimer), findsOneWidget);
    await tester.tap(find.text(Copy.endEarly));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(Copy.endedEarly), findsOneWidget);

    await tester.tap(find.text(Copy.backHome));
    await tester.pumpAndSettle();
  });
}
