import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_widgets.dart';
import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/app_state.dart';
import '../../l10n/copy.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  int _focus = 3;
  int _energy = 3;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(appStateProvider.notifier)
        .addReflection(
          focusRating: _focus,
          energyRating: _energy,
          note: _noteController.text,
        );
    _noteController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(Copy.saved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final entries = state.reflections;
    return AppScaffold(
      selectedIndex: 1,
      title: Copy.reflect,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
            children: [
              Text(
                Copy.reflectionTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 7),
              Text(
                Copy.reflectionBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RatingQuestion(
                      title: Copy.focusRating,
                      value: _focus,
                      onChanged: (value) => setState(() => _focus = value),
                    ),
                    const Divider(height: 28),
                    _RatingQuestion(
                      title: Copy.energyRating,
                      value: _energy,
                      onChanged: (value) => setState(() => _energy = value),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      maxLength: 300,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: Copy.noteLabel,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.bookmark_outline),
                      label: const Text(Copy.saveReflection),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => _noteController.clear(),
                        child: const Text(Copy.skipReflection),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                Copy.pastReflections,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                SurfaceCard(
                  child: Text(
                    Copy.noneReflections,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ...entries
                    .take(20)
                    .map(
                      (entry) => _ReflectionTile(
                        entry: entry,
                        onDelete: () => ref
                            .read(appStateProvider.notifier)
                            .deleteReflection(entry.id),
                      ),
                    ),
              const SizedBox(height: 14),
              Text(
                Copy.notMedical,
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

class _RatingQuestion extends StatelessWidget {
  const _RatingQuestion({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      Slider(
        value: value.toDouble(),
        min: 1,
        max: 5,
        divisions: 4,
        label: Copy.ratingLabel(value),
        onChanged: (next) => onChanged(next.round()),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Copy.noteScaleLow, style: Theme.of(context).textTheme.bodySmall),
          Text(
            '$value / 5',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: AppTheme.teal, fontWeight: FontWeight.bold),
          ),
          Text(
            Copy.noteScaleHigh,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ],
  );
}

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({required this.entry, required this.onDelete});
  final ReflectionEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEE, MMM d • h:mm a')
                      .format(entry.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: Copy.deleteData,
              ),
            ],
          ),
          Text(
            Copy.reflectionSummary(entry.focusRating, entry.energyRating),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(entry.note, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ],
      ),
    ),
  );
}
