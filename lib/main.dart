import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final store = SharedPreferencesAppStore(preferences);
  runApp(
    ProviderScope(
      overrides: [appStoreProvider.overrideWithValue(store)],
      child: const StillwellApp(),
    ),
  );
}
