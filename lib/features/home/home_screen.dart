import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_widgets.dart';
import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/app_state.dart';
import '../../l10n/copy.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final preferences = state.preferences;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? Copy.goodMorning
        : hour < 18
        ? Copy.goodAfternoon
        : Copy.goodEvening;
    final weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final sessionsThisWeek = state.sessions
        .where(
          (session) => session.startedAt.toLocal().isAfter(
            DateTime(weekStart.year, weekStart.month, weekStart.day),
          ),
        )
        .length;
    final goal = preferences.weeklyFocusGoal;
    final active = state.activeSession;

    return AppScaffold(
      selectedIndex: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.spa_outlined, color: AppTheme.teal),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      Copy.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      DateFormat('EEE, MMM d').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(Copy.tagline, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 22),
              SurfaceCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel(Copy.yourIntention),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.spa_outlined, color: AppTheme.teal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _intentionLabel(preferences.intention),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => context.push('/focus'),
                      icon: Icon(
                        active == null
                            ? Icons.play_arrow_rounded
                            : Icons.timer_outlined,
                      ),
                      label: Text(
                        active == null ? Copy.startFocus : Copy.returnToFocus,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Copy.focusDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: AppTheme.teal,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            Copy.yourWeek,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$sessionsThisWeek',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              Copy.sessionUnit(sessionsThisWeek),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (goal != null)
                          Text(
                            '$sessionsThisWeek / $goal',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      goal == null
                          ? (sessionsThisWeek == 0
                                ? Copy.noSessions
                                : Copy.smallPause)
                          : Copy.goalProgress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (goal != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: (sessionsThisWeek / goal)
                              .clamp(0, 1)
                              .toDouble(),
                          minHeight: 8,
                          backgroundColor: AppTheme.mint,
                          color: AppTheme.teal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.insights_outlined, color: AppTheme.muted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Copy.usageUnavailable,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Copy.usageDetail,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              TextButton.icon(
                onPressed: () => context.go('/reflect'),
                icon: const Icon(Icons.spa_outlined),
                label: const Text(Copy.reflectCta),
              ),
              const SizedBox(height: 8),
              Text(
                Copy.disclaimer,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _intentionLabel(IntentionCategory category) => switch (category) {
  IntentionCategory.study => Copy.study,
  IntentionCategory.bedtime => Copy.bedtime,
  IntentionCategory.lessChecking => Copy.lessChecking,
  IntentionCategory.bePresent => Copy.bePresent,
};
