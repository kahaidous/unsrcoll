// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Stillwell';

  @override
  String get tagline => 'A little more intention. A little less autopilot.';

  @override
  String get welcomeTitle => 'Make room for what matters.';

  @override
  String get welcomeBody =>
      'Notice the moments that pull you into scrolling, then try a small routine that feels right for you.';

  @override
  String get disclaimer =>
      '“Brain rot” is an informal phrase, not a medical diagnosis. Stillwell is a habit-support tool, not medical care.';

  @override
  String get home => 'Today';

  @override
  String get reflect => 'Reflect';

  @override
  String get settings => 'Settings';

  @override
  String get startFocus => 'Start a focus session';

  @override
  String get focusTitle => 'Set a focus window';

  @override
  String get beginFocus => 'Begin focus';

  @override
  String get endEarly => 'End session';

  @override
  String get saveReflection => 'Save reflection';

  @override
  String get exportData => 'Export my data';

  @override
  String get deleteData => 'Delete all local data';
}
