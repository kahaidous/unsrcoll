import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_state.dart';

abstract interface class AppStore {
  AppState load();
  Future<void> save(AppState state);
  Future<void> clear();
  String exportJson(AppState state);
}

/// Preference-backed local persistence for the first manual-mode milestone.
/// A future SQLite/Drift migration can implement [AppStore] without changing UI.
class SharedPreferencesAppStore implements AppStore {
  SharedPreferencesAppStore(this._preferences);

  static const storageKey = 'intentional_phone_use_state_v1';
  final SharedPreferences _preferences;

  @override
  AppState load() {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const AppState();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return AppState.fromJson(decoded);
    } on FormatException {
      // Recover to manual mode if local data is incomplete or unreadable.
    } on TypeError {
      // Recover to manual mode if a previous schema contains invalid values.
    }
    return const AppState();
  }

  @override
  Future<void> save(AppState state) async {
    await _preferences.setString(storageKey, jsonEncode(state.toJson()));
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(storageKey);
  }

  @override
  String exportJson(AppState state) =>
      const JsonEncoder.withIndent('  ').convert(state.toJson());
}
