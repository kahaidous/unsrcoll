import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/focus/focus_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/reflection/reflection_screen.dart';
import '../features/settings/settings_screen.dart';
import '../l10n/copy.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeRouterScreen()),
    GoRoute(path: '/focus', builder: (context, state) => const FocusScreen()),
    GoRoute(
      path: '/reflect',
      builder: (context, state) => const ReflectionScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class StillwellApp extends StatelessWidget {
  const StillwellApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: Copy.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    routerConfig: _router,
    supportedLocales: const [Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
  );
}
