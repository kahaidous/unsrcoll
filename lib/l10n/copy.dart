/// Centralized English copy for the initial release. Keep language gentle,
/// non-clinical and free of claims that the app can reverse cognitive changes.
abstract final class Copy {
  static const appName = 'Stillwell';
  static const tagline = 'A little more intention. A little less autopilot.';
  static const disclaimer =
      '“Brain rot” is an informal phrase, not a medical diagnosis. Stillwell is a habit-support tool, not medical care.';
  static const welcomeTitle = 'Make room for what matters.';
  static const welcomeBody =
      'Notice the moments that pull you into scrolling, then try a small routine that feels right for you.';
  static const chooseIntention = 'What would you like to make space for?';
  static const chooseStyle = 'Choose your starting style';
  static const goalQuestion = 'Would a small weekly focus goal help?';
  static const noGoal = 'I’ll decide as I go';
  static const startJourney = 'Set up my space';
  static const skipSetup = 'Skip setup';
  static const study = 'Protect study time';
  static const bedtime = 'A calmer bedtime';
  static const lessChecking = 'Check less automatically';
  static const bePresent = 'Be more present';
  static const awareness = 'Awareness';
  static const awarenessDetail = 'Pause and notice your habits';
  static const gentleNudges = 'Gentle nudges';
  static const gentleNudgesDetail = 'Add a light reminder to pause';
  static const focusWindows = 'Focus windows';
  static const focusWindowsDetail = 'Set aside time for one thing';
  static const goodMorning = 'A calmer start, on your terms.';
  static const goodAfternoon = 'Make a little room for focus.';
  static const goodEvening = 'Let the day slow down.';
  static const yourIntention = 'YOUR INTENTION';
  static const startFocus = 'Start a focus session';
  static const returnToFocus = 'Return to your focus session';
  static const focusDescription =
      'A simple timer for a phone-down moment. Nothing is blocked.';
  static const yourWeek = 'Your week, gently';
  static const sessions = 'sessions';
  static const noSessions = 'Your first session is a fresh start.';
  static const smallPause = 'A small pause still counts.';
  static const usageUnavailable =
      'Phone usage insights aren’t enabled in this version.';
  static const usageDetail =
      'Your focus timer and reflections still work offline, with no permissions.';
  static const focusTitle = 'Set a focus window';
  static const chooseDuration = 'Choose a duration';
  static const beginFocus = 'Begin focus';
  static const focusActive = 'Your time, your pace.';
  static const timerDisclaimer =
      'This is a self-guided timer. Other apps are not blocked.';
  static const endEarly = 'End session';
  static const sessionDone = 'You made a little space.';
  static const completed = 'Focus session complete';
  static const endedEarly = 'Session ended early';
  static const backHome = 'Back to today';
  static const reflect = 'Reflect';
  static const reflectionTitle = 'A quick check-in';
  static const reflectionBody =
      'Optional, private, and just for you. There are no right answers.';
  static const focusRating = 'How focused did you feel?';
  static const energyRating = 'How was your energy?';
  static const noteLabel = 'Anything you want to remember? (optional)';
  static const saveReflection = 'Save reflection';
  static const skipReflection = 'Not now';
  static const pastReflections = 'Your check-ins';
  static const noneReflections = 'No check-ins yet. You can always skip.';
  static const home = 'Today';
  static const settings = 'Settings';
  static const preferences = 'Your preferences';
  static const dataPrivacy = 'Your data stays in this app';
  static const dataPrivacyDetail =
      'No account, ads, or remote analytics. Your notes are saved locally. Device backup behavior follows your operating-system settings.';
  static const exportData = 'Export my data';
  static const deleteData = 'Delete all local data';
  static const deleteConfirmTitle = 'Delete everything on this device?';
  static const deleteConfirmBody =
      'This permanently removes your preferences, focus history and reflections from this app.';
  static const cancel = 'Cancel';
  static const delete = 'Delete';
  static const capabilityTitle = 'Optional phone controls';
  static const capabilityDetail =
      'Automatic usage insights, app blocking and launch prompts are not available yet. They need separate iOS and Android feasibility and store-policy reviews.';
  static const intensity = 'Intervention style';
  static const weeklyGoal = 'Weekly focus goal';
  static const noGoalSet = 'No goal set';
  static const goalProgress = 'This week';
  static const saved = 'Saved on this device';
  static const permissionFree = 'No permissions needed';
  static const notMedical =
      'If sleep or distress is persistently affecting daily life, consider talking with a qualified health professional.';
  static const goalSet = 'Your goal can be changed or removed anytime.';
  static const dataExported = 'Your export is ready to share.';
  static const decreaseGoal = 'Decrease weekly goal';
  static const increaseGoal = 'Increase weekly goal';
  static const durationMinutes = 'min';
  static const remaining = 'remaining';
  static const timerElapsed = 'Focus time elapsed';
  static const noStreak =
      'No streaks to protect and nothing to make up. Simply notice how it felt.';
  static const decrease = 'A little';
  static const increase = 'A lot';
  static const focusScore = 'Focus';
  static const energyScore = 'Energy';
  static const shareExport = 'Share your private data export';
  static const exportFailed = 'Could not prepare the export. Please try again.';
  static const reflectCta = 'Take a gentle check-in';
  static const focusWindowIntro = 'One small window.';
  static const focusWindowPrompt =
      'Pick an amount of time that feels doable. You can end early, anytime.';
  static const focusNotAvailable = 'Not available on this device yet';
  static const needsAuthorization = 'Needs authorization';
  static const notAuthorized = 'Not authorized';
  static const capabilityUnknown = 'Status unknown';
  static const capabilityUsage = 'Phone usage summary';
  static const capabilityBlocking = 'Selected-app blocking';
  static const capabilityLaunch = 'App-launch pause';
  static const capabilitySchedules = 'Scheduled monitoring';
  static const noteScaleLow = 'A little';
  static const noteScaleHigh = 'A lot';
  static const focusControlChecks = 'Flutter checks';
  static const focusSession = 'focus session';
  static const focusSessions = 'focus sessions';
  static const capabilityLoading = 'Checking platform capabilities…';
  static const authorized = 'Authorized';
  static const restricted = 'Restricted by device settings';

  static String weeklyGoalLabel(int sessions) =>
      '$sessions ${sessions == 1 ? focusSession : focusSessions} per week';
  static String targetSessionsLabel(int sessions) =>
      '$sessions ${sessions == 1 ? focusSession : focusSessions}';
  static String durationLabel(int minutes) => '$minutes $durationMinutes';
  static String weeklyCountLabel(int sessions) =>
      '$sessions ${sessions == 1 ? 'session' : 'sessions'}';
  static String sessionUnit(int sessions) =>
      sessions == 1 ? 'session' : 'sessions';
  static String ratingLabel(int value) => '$value of 5';
  static String reflectionSummary(int focus, int energy) =>
      '$focusScore $focus/5 · $energyScore $energy/5';
}
