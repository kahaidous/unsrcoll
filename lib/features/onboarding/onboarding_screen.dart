import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_widgets.dart';
import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/app_state.dart';
import '../../l10n/copy.dart';
import '../home/home_screen.dart';

class HomeRouterScreen extends ConsumerWidget {
  const HomeRouterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complete = ref.watch(appStateProvider).preferences.onboardingComplete;
    return complete ? const TodayScreen() : const OnboardingScreen();
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  IntentionCategory _intention = IntentionCategory.study;
  InterventionLevel _level = InterventionLevel.awareness;
  bool _goalEnabled = false;
  int _weeklyGoal = 3;
  bool _saving = false;

  Future<void> _finish({bool skip = false}) async {
    setState(() => _saving = true);
    final current = ref.read(appStateProvider).preferences;
    await ref
        .read(appStateProvider.notifier)
        .savePreferences(
          current.copyWith(
            onboardingComplete: true,
            intention: skip ? current.intention : _intention,
            interventionLevel: skip ? current.interventionLevel : _level,
            weeklyFocusGoal: skip || !_goalEnabled ? null : _weeklyGoal,
            clearWeeklyFocusGoal: skip || !_goalEnabled,
          ),
        );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.mint,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.spa_outlined,
                        color: AppTheme.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        Copy.appName,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: _saving ? null : () => _finish(skip: true),
                      child: const Text(Copy.skipSetup),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Text(Copy.welcomeTitle, style: theme.textTheme.headlineLarge),
                const SizedBox(height: 12),
                Text(Copy.welcomeBody, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 20),
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.teal,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          Copy.disclaimer,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(Copy.chooseIntention, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                ...IntentionCategory.values.map(
                  (value) => _ChoiceTile(
                    title: _intentionLabel(value),
                    icon: _intentionIcon(value),
                    selected: _intention == value,
                    onTap: () => setState(() => _intention = value),
                  ),
                ),
                const SizedBox(height: 18),
                Text(Copy.chooseStyle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                ...InterventionLevel.values.map(
                  (value) => _ChoiceTile(
                    title: _levelTitle(value),
                    subtitle: _levelDescription(value),
                    icon: _levelIcon(value),
                    selected: _level == value,
                    onTap: () => setState(() => _level = value),
                  ),
                ),
                const SizedBox(height: 18),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Copy.goalQuestion,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(Copy.goalSet, style: theme.textTheme.bodyMedium),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _goalEnabled
                              ? Copy.weeklyGoalLabel(_weeklyGoal)
                              : Copy.noGoal,
                        ),
                        value: _goalEnabled,
                        onChanged: (value) =>
                            setState(() => _goalEnabled = value),
                      ),
                      if (_goalEnabled)
                        Row(
                          children: [
                            IconButton(
                              onPressed: _weeklyGoal > 1
                                  ? () => setState(() => _weeklyGoal--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              tooltip: Copy.decreaseGoal,
                            ),
                            Expanded(
                              child: Slider(
                                value: _weeklyGoal.toDouble(),
                                min: 1,
                                max: 7,
                                divisions: 6,
                                label: '$_weeklyGoal',
                                onChanged: (value) =>
                                    setState(() => _weeklyGoal = value.round()),
                              ),
                            ),
                            IconButton(
                              onPressed: _weeklyGoal < 7
                                  ? () => setState(() => _weeklyGoal++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              tooltip: Copy.increaseGoal,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _finish(),
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text(Copy.startJourney),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    Copy.permissionFree,
                    style: TextStyle(color: AppTheme.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: selected ? AppTheme.mint : AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppTheme.teal : AppTheme.muted),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppTheme.teal : AppTheme.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _intentionLabel(IntentionCategory category) => switch (category) {
  IntentionCategory.study => Copy.study,
  IntentionCategory.bedtime => Copy.bedtime,
  IntentionCategory.lessChecking => Copy.lessChecking,
  IntentionCategory.bePresent => Copy.bePresent,
};
IconData _intentionIcon(IntentionCategory category) => switch (category) {
  IntentionCategory.study => Icons.menu_book_outlined,
  IntentionCategory.bedtime => Icons.nightlight_outlined,
  IntentionCategory.lessChecking => Icons.touch_app_outlined,
  IntentionCategory.bePresent => Icons.nature_people_outlined,
};
String _levelTitle(InterventionLevel level) => switch (level) {
  InterventionLevel.awareness => Copy.awareness,
  InterventionLevel.gentleNudges => Copy.gentleNudges,
  InterventionLevel.focusWindows => Copy.focusWindows,
};
String _levelDescription(InterventionLevel level) => switch (level) {
  InterventionLevel.awareness => Copy.awarenessDetail,
  InterventionLevel.gentleNudges => Copy.gentleNudgesDetail,
  InterventionLevel.focusWindows => Copy.focusWindowsDetail,
};
IconData _levelIcon(InterventionLevel level) => switch (level) {
  InterventionLevel.awareness => Icons.visibility_outlined,
  InterventionLevel.gentleNudges => Icons.waves_outlined,
  InterventionLevel.focusWindows => Icons.timer_outlined,
};
