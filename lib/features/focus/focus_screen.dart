import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_widgets.dart';
import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/app_state.dart';
import '../../l10n/copy.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with WidgetsBindingObserver {
  int _minutes = 25;
  Timer? _ticker;
  String? _shownSessionId;
  bool _completedHere = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final active = ref.read(appStateProvider).activeSession;
    _shownSessionId = active?.id;
    if (active != null) _startTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(appStateProvider.notifier).refreshFocus());
      _tick();
    }
  }

  void _tick() {
    final active = ref.read(appStateProvider).activeSession;
    if (active == null) {
      _ticker?.cancel();
      _ticker = null;
      if (_shownSessionId != null && !_completedHere && mounted) {
        setState(() => _completedHere = true);
      }
      return;
    }
    _shownSessionId = active.id;
    if (!DateTime.now().toUtc().isBefore(active.endsAt)) {
      unawaited(ref.read(appStateProvider.notifier).refreshFocus());
    }
    if (mounted) setState(() {});
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final active = state.activeSession;
    if (active != null) _shownSessionId = active.id;
    final previousSession = _shownSessionId == null
        ? null
        : state.sessions
              .where((session) => session.id == _shownSessionId)
              .firstOrNull;
    final isDone =
        _completedHere ||
        (active == null &&
            previousSession != null &&
            previousSession.completed);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Copy.focusTitle),
        backgroundColor: AppTheme.canvas,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
          tooltip: Copy.home,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              children: [
                if (active != null)
                  _ActiveSessionView(
                    session: active,
                    onEnd: () async {
                      await ref
                          .read(appStateProvider.notifier)
                          .finishFocus(early: true);
                      if (mounted) setState(() => _completedHere = true);
                    },
                    onComplete: () async {
                      await ref.read(appStateProvider.notifier).finishFocus();
                      if (mounted) setState(() => _completedHere = true);
                    },
                  )
                else if (isDone)
                  _SessionCompleteView(
                    completed: previousSession?.completed ?? false,
                  )
                else
                  _FocusSetupView(
                    selectedMinutes: _minutes,
                    onDurationSelected: (value) =>
                        setState(() => _minutes = value),
                    onStart: () async {
                      await ref
                          .read(appStateProvider.notifier)
                          .startFocus(minutes: _minutes);
                      final session = ref.read(appStateProvider).activeSession;
                      if (mounted) {
                        setState(() => _shownSessionId = session?.id);
                        if (session != null) _startTicker();
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusSetupView extends StatelessWidget {
  const _FocusSetupView({
    required this.selectedMinutes,
    required this.onDurationSelected,
    required this.onStart,
  });
  final int selectedMinutes;
  final ValueChanged<int> onDurationSelected;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(
        Copy.focusWindowIntro,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 8),
      Text(
        Copy.focusWindowPrompt,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 30),
      const SectionLabel(Copy.chooseDuration),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [10, 15, 25, 45]
            .map(
              (minutes) => ChoiceChip(
                label: Text(Copy.durationLabel(minutes)),
                selected: selectedMinutes == minutes,
                onSelected: (_) => onDurationSelected(minutes),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 28),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.spa_outlined, color: AppTheme.teal),
            const SizedBox(height: 12),
            Text(
              Copy.focusActive,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              Copy.timerDisclaimer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text(Copy.beginFocus),
      ),
      const SizedBox(height: 12),
      const Center(
        child: Text(
          Copy.permissionFree,
          style: TextStyle(color: AppTheme.muted),
        ),
      ),
    ],
  );
}

class _ActiveSessionView extends StatelessWidget {
  const _ActiveSessionView({
    required this.session,
    required this.onEnd,
    required this.onComplete,
  });
  final FocusSession session;
  final VoidCallback onEnd;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final remaining = session.endsAt.difference(DateTime.now().toUtc());
    final seconds = remaining.inSeconds.clamp(0, 60 * 60 * 24);
    if (seconds == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
    }
    final total = session.endsAt.difference(session.startedAt).inSeconds;
    final progress = total <= 0 ? 1.0 : (1 - seconds / total).clamp(0.0, 1.0);
    return Column(
      children: [
        const SizedBox(height: 18),
        Text(
          Copy.focusActive,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _intentionLabel(session.intention),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 36),
        SizedBox.square(
          dimension: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppTheme.mint,
                  color: AppTheme.teal,
                  semanticsLabel: Copy.timerElapsed,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _format(seconds),
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(fontSize: 50, fontFeatures: const []),
                  ),
                  Text(
                    Copy.remaining,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SurfaceCard(
          child: Column(
            children: [
              const Icon(Icons.phone_iphone_outlined, color: AppTheme.teal),
              const SizedBox(height: 10),
              Text(
                Copy.timerDisclaimer,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton(onPressed: onEnd, child: const Text(Copy.endEarly)),
      ],
    );
  }
}

class _SessionCompleteView extends StatelessWidget {
  const _SessionCompleteView({required this.completed});
  final bool completed;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 45),
      Container(
        width: 92,
        height: 92,
        decoration: const BoxDecoration(
          color: AppTheme.mint,
          shape: BoxShape.circle,
        ),
        child: Icon(
          completed ? Icons.check_rounded : Icons.spa_outlined,
          color: AppTheme.teal,
          size: 46,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        Copy.sessionDone,
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        completed ? Copy.completed : Copy.endedEarly,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 10),
      Text(
        Copy.noStreak,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 26),
      FilledButton(
        onPressed: () => context.go('/reflect'),
        child: const Text(Copy.reflect),
      ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: () => context.go('/'),
        child: const Text(Copy.backHome),
      ),
    ],
  );
}

String _format(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
}

String _intentionLabel(IntentionCategory category) => switch (category) {
  IntentionCategory.study => Copy.study,
  IntentionCategory.bedtime => Copy.bedtime,
  IntentionCategory.lessChecking => Copy.lessChecking,
  IntentionCategory.bePresent => Copy.bePresent,
};

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
