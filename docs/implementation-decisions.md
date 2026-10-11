# Implementation decisions

## Product framing

Stillwell is an adults-first intentional-phone-use coach. “Brain rot” is informal language, not a diagnosis. The app offers small, user-chosen routines; it does not diagnose, treat, or promise cognitive recovery.

## Initial milestone

The first Flutter milestone is permission-independent: optional onboarding, intention and weekly focus goal, a recoverable self-guided focus timer, optional private reflection, local export, and delete-all. The timer does not block or monitor other apps. No account, server, ads, analytics SDK, social feed or notification schedule is included.

## Platform capability boundary

`PlatformInterventionService` is the boundary for OS-dependent features. The current adapter reports all capabilities as unsupported. Replace it only after:

- Android Usage Access and aggregate accuracy are verified across representative OEMs; AccessibilityService is not an MVP dependency and needs separate policy approval.
- iOS FamilyControls / DeviceActivity / ManagedSettings entitlement, authorization, report boundaries and extension targets are validated for the shipping account and App Store path.
- Denied, revoked and unsupported states have visible fallbacks and tests.

Never infer that a feature is active from the platform name alone. Do not claim a screen-time measurement, launch pause or block until the native adapter confirms it.

## Local storage trade-off

The first implementation stores a versioned JSON document in app-local preferences behind `AppStore`. This keeps the prototype offline and replaceable, but is not intended for large histories or encrypted-database guarantees. Before expanding reflection/history storage, migrate to a tested SQLite/Drift repository, assess at-rest protection and OS backup behavior, and provide explicit migrations/export/delete coverage.

## Verification scope

Linux CI runs formatting, Flutter analysis and unit/widget tests. It does not prove iOS entitlements, Android OEM behavior, store approval, signing or real-device battery behavior. Those require dedicated Android and Apple platform testing before release.
