# Stillwell — Intentional Phone Use Coach

A privacy-first, adults-first habit-support app for iOS and Android, built with Flutter. The first milestone focuses on self-guided focus sessions and private reflection. It does not diagnose or treat a condition, and it does not claim to reverse cognitive changes.

> “Brain rot” is informal language, not a medical diagnosis. The supplied research brief describes mostly correlational evidence and mixed intervention findings; Stillwell offers small, user-chosen experiments rather than a cure.

## Current milestone

- Flutter 3.47 / Dart 3.13, Material 3, Riverpod and go_router.
- Offline-first, on-device preference-backed storage; no account, backend, ads or analytics SDK.
- Optional onboarding intention and weekly focus goal.
- Focus timer stores its planned end time, so it can recover after ordinary app backgrounding or restart.
- Optional self-rated check-ins, private data export and delete-all controls.
- Manual mode works without OS permissions.
- OS usage reports, app blocking, launch interception, schedules and notifications are intentionally **not enabled**. They remain gated on native API, entitlement, reliability and store-policy validation.

The supplied architecture specification remains the product authority. This initial preference-backed store is an adapter intended to be replaceable by a migrated database implementation before storing substantial history.

## Run locally

```sh
flutter pub get
flutter run
```

Android and iOS project scaffolds are included. This Linux development environment can run Flutter tests and static analysis; Android SDK/Xcode signing and Apple Screen Time entitlement validation require their respective platform environments and accounts.

## Verify

```sh
flutter analyze
flutter test
```

## Privacy and safety

All records remain in app-local storage. Reflection notes can contain sensitive personal text; they are not uploaded or logged. Export is user initiated. Erasing data returns the app to first-run onboarding. Usage/blocking feature claims must not be added until their platform-specific capability has actually been authorized and verified.
