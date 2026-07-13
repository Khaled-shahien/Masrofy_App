# Masrofy

Masrofy is a local-first Flutter expense tracker for recording income and
expenses, reviewing monthly reports, managing wallets and category budgets, and
creating local backups.

## Privacy model

Masrofy keeps app data on the user's device. It does not include a backend,
cloud sync, Firebase, notifications, advertising, subscriptions, or third-party
analytics.

## Development

Common validation commands:

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```
