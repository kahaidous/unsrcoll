import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_widgets.dart';
import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/app_state.dart';
import '../../l10n/copy.dart';
import '../../platform/capabilities.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    File? exportFile;
    try {
      final state = ref.read(appStateProvider);
      final store = ref.read(appStoreProvider);
      final directory = await getTemporaryDirectory();
      exportFile = File(
        '${directory.path}/stillwell-data-export-${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await exportFile.writeAsString(store.exportJson(state), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          title: Copy.shareExport,
          files: [XFile(exportFile.path, mimeType: 'application/json')],
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(Copy.exportFailed)));
      }
    } finally {
      try {
        if (exportFile != null && await exportFile.exists()) {
          await exportFile.delete();
        }
      } catch (_) {
        // OS temporary-directory cleanup remains a fallback if sharing fails.
      }
    }
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Copy.deleteConfirmTitle),
        content: const Text(Copy.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(Copy.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Copy.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appStateProvider.notifier).eraseAllData();
      if (context.mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appStateProvider).preferences;
    final controller = ref.read(appStateProvider.notifier);
    final capabilities = ref.watch(platformCapabilitiesProvider);
    return AppScaffold(
      selectedIndex: 2,
      title: Copy.settings,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            children: [
              Text(
                Copy.preferences,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<IntentionCategory>(
                      initialValue: preferences.intention,
                      decoration: const InputDecoration(
                        labelText: Copy.yourIntention,
                      ),
                      items: IntentionCategory.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_intentionLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.savePreferences(
                            preferences.copyWith(intention: value),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<InterventionLevel>(
                      initialValue: preferences.interventionLevel,
                      decoration: const InputDecoration(
                        labelText: Copy.intensity,
                      ),
                      items: InterventionLevel.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_levelLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.savePreferences(
                            preferences.copyWith(interventionLevel: value),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      Copy.weeklyGoal,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        preferences.weeklyFocusGoal == null
                            ? Copy.noGoalSet
                            : Copy.targetSessionsLabel(
                                preferences.weeklyFocusGoal!,
                              ),
                      ),
                      value: preferences.weeklyFocusGoal != null,
                      onChanged: (enabled) => controller.savePreferences(
                        preferences.copyWith(
                          weeklyFocusGoal: enabled ? 3 : null,
                          clearWeeklyFocusGoal: !enabled,
                        ),
                      ),
                    ),
                    if (preferences.weeklyFocusGoal != null)
                      Slider(
                        value: preferences.weeklyFocusGoal!.toDouble(),
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: '${preferences.weeklyFocusGoal}',
                        onChanged: (value) => controller.savePreferences(
                          preferences.copyWith(weeklyFocusGoal: value.round()),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppTheme.teal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            Copy.dataPrivacy,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Copy.dataPrivacyDetail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      Copy.saved,
                      style: TextStyle(
                        color: AppTheme.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.devices_outlined,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            Copy.capabilityTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Copy.capabilityDetail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    capabilities.when(
                      data: (snapshot) => Column(
                        children: [
                          for (final capability in PlatformCapability.values)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(_capabilityLabel(capability)),
                              trailing: Text(
                                _statusLabel(snapshot.statusFor(capability)),
                              ),
                            ),
                        ],
                      ),
                      loading: () => const Text(Copy.capabilityLoading),
                      error: (error, stackTrace) =>
                          const Text(Copy.capabilityDetail),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _export(context, ref),
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text(Copy.exportData),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _deleteAll(context, ref),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text(
                  Copy.deleteData,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                Copy.notMedical,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
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
String _levelLabel(InterventionLevel level) => switch (level) {
  InterventionLevel.awareness => Copy.awareness,
  InterventionLevel.gentleNudges => Copy.gentleNudges,
  InterventionLevel.focusWindows => Copy.focusWindows,
};

String _capabilityLabel(PlatformCapability capability) => switch (capability) {
  PlatformCapability.usageRead => Copy.capabilityUsage,
  PlatformCapability.selectedAppBlocking => Copy.capabilityBlocking,
  PlatformCapability.launchInterruption => Copy.capabilityLaunch,
  PlatformCapability.scheduledMonitoring => Copy.capabilitySchedules,
};

String _statusLabel(CapabilityStatus status) => switch (status) {
  CapabilityStatus.available => Copy.needsAuthorization,
  CapabilityStatus.authorized => Copy.authorized,
  CapabilityStatus.denied => Copy.notAuthorized,
  CapabilityStatus.restricted => Copy.restricted,
  CapabilityStatus.unsupported => Copy.focusNotAvailable,
  CapabilityStatus.error => Copy.capabilityUnknown,
};
