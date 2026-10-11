/// Domain values stored only on this device. No account or remote sync exists.
enum IntentionCategory { study, bedtime, lessChecking, bePresent }

enum InterventionLevel { awareness, gentleNudges, focusWindows }

class AppPreferences {
  const AppPreferences({
    this.onboardingComplete = false,
    this.intention = IntentionCategory.study,
    this.interventionLevel = InterventionLevel.awareness,
    this.weeklyFocusGoal,
  });

  final bool onboardingComplete;
  final IntentionCategory intention;
  final InterventionLevel interventionLevel;
  final int? weeklyFocusGoal;

  AppPreferences copyWith({
    bool? onboardingComplete,
    IntentionCategory? intention,
    InterventionLevel? interventionLevel,
    int? weeklyFocusGoal,
    bool clearWeeklyFocusGoal = false,
  }) => AppPreferences(
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    intention: intention ?? this.intention,
    interventionLevel: interventionLevel ?? this.interventionLevel,
    weeklyFocusGoal: clearWeeklyFocusGoal
        ? null
        : weeklyFocusGoal ?? this.weeklyFocusGoal,
  );

  Map<String, Object?> toJson() => {
    'onboardingComplete': onboardingComplete,
    'intention': intention.name,
    'interventionLevel': interventionLevel.name,
    'weeklyFocusGoal': weeklyFocusGoal,
  };

  factory AppPreferences.fromJson(Map<String, dynamic> json) => AppPreferences(
    onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    intention: _enumValue(
      IntentionCategory.values,
      json['intention'],
      IntentionCategory.study,
    ),
    interventionLevel: _enumValue(
      InterventionLevel.values,
      json['interventionLevel'],
      InterventionLevel.awareness,
    ),
    weeklyFocusGoal: (json['weeklyFocusGoal'] as num?)?.toInt(),
  );
}

class FocusSession {
  const FocusSession({
    required this.id,
    required this.startedAt,
    required this.endsAt,
    required this.intention,
    this.endedAt,
    this.completed = false,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endsAt;
  final DateTime? endedAt;
  final IntentionCategory intention;
  final bool completed;

  bool get isActive => endedAt == null;

  FocusSession finish({required DateTime at, required bool completed}) =>
      FocusSession(
        id: id,
        startedAt: startedAt,
        endsAt: endsAt,
        endedAt: at,
        intention: intention,
        completed: completed,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'endsAt': endsAt.toUtc().toIso8601String(),
    'endedAt': endedAt?.toUtc().toIso8601String(),
    'intention': intention.name,
    'completed': completed,
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    id: json['id'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
    endsAt: DateTime.parse(json['endsAt'] as String).toUtc(),
    endedAt: json['endedAt'] == null
        ? null
        : DateTime.parse(json['endedAt'] as String).toUtc(),
    intention: _enumValue(
      IntentionCategory.values,
      json['intention'],
      IntentionCategory.study,
    ),
    completed: json['completed'] as bool? ?? false,
  );
}

class ReflectionEntry {
  const ReflectionEntry({
    required this.id,
    required this.createdAt,
    required this.focusRating,
    required this.energyRating,
    this.note = '',
  });

  final String id;
  final DateTime createdAt;
  final int focusRating;
  final int energyRating;
  final String note;

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'focusRating': focusRating,
    'energyRating': energyRating,
    'note': note,
  };

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) =>
      ReflectionEntry(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
        focusRating: (json['focusRating'] as num).toInt().clamp(1, 5).toInt(),
        energyRating: (json['energyRating'] as num).toInt().clamp(1, 5).toInt(),
        note: json['note'] as String? ?? '',
      );
}

class AppState {
  const AppState({
    this.preferences = const AppPreferences(),
    this.sessions = const [],
    this.reflections = const [],
  });

  final AppPreferences preferences;
  final List<FocusSession> sessions;
  final List<ReflectionEntry> reflections;

  FocusSession? get activeSession {
    for (final session in sessions.reversed) {
      if (session.isActive) return session;
    }
    return null;
  }

  AppState copyWith({
    AppPreferences? preferences,
    List<FocusSession>? sessions,
    List<ReflectionEntry>? reflections,
  }) => AppState(
    preferences: preferences ?? this.preferences,
    sessions: sessions ?? this.sessions,
    reflections: reflections ?? this.reflections,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'preferences': preferences.toJson(),
    'sessions': sessions.map((session) => session.toJson()).toList(),
    'reflections': reflections.map((entry) => entry.toJson()).toList(),
  };

  factory AppState.fromJson(Map<String, dynamic> json) {
    final rawPreferences = json['preferences'];
    final rawSessions = json['sessions'];
    final rawReflections = json['reflections'];
    return AppState(
      preferences: rawPreferences is Map<String, dynamic>
          ? AppPreferences.fromJson(rawPreferences)
          : const AppPreferences(),
      sessions: rawSessions is List
          ? rawSessions
                .whereType<Map<String, dynamic>>()
                .map(FocusSession.fromJson)
                .toList()
          : const [],
      reflections: rawReflections is List
          ? rawReflections
                .whereType<Map<String, dynamic>>()
                .map(ReflectionEntry.fromJson)
                .toList()
          : const [],
    );
  }
}

T _enumValue<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
