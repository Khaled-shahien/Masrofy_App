# Masrofy Stabilization, Branding, and Onboarding Report

## 1. Executive Summary

Implemented the coordinated Masrofy stabilization pass across startup, storage security, biometrics, transaction validation, wallet readiness, offline PDF fonts, backup picking, branding, native splash, Flutter bootstrap splash, onboarding, metadata, and tests.

The app now has a single bootstrap path, fail-closed storage behavior, sanitized encrypted quarantine metadata, real biometric unlock through an abstraction, first-run onboarding with existing-user migration, generated launcher icons and splash assets, and local bundled Arabic/Latin PDF fonts.

## 2. Initial Repository State

Initial branch: `main`.

Initial HEAD: `33c75c1b564fdee96155f68634dd0ff6847e867c`.

Initial working tree already contained user changes:

- `FLUTTER_PROJECT_ANALYSIS.md` modified.
- `MASROFY_UI_UX_IMPLEMENTATION_REPORT.md` deleted.
- `codex_flutter_full_review_prompt.md` deleted.
- `codex_ui_ux_deep_enhancement_prompt.md` deleted.
- `assets/images/logos/logo1.jpg` untracked.
- `assets/images/logos/logo2.png` untracked.

Those pre-existing changes were preserved and not reverted.

## 3. Baseline Validation

Baseline before implementation:

- `flutter pub get`: passed.
- `flutter analyze`: passed.
- `flutter test`: passed, 111 tests.
- Flutter: `3.42.0-0.4.pre`.
- Dart: `3.12.0-113.2.beta`.

## 4. Startup Architecture Before and After

Before: `main.dart` initialized storage and GetIt before `runApp`, while `MasrofyBootstrapApp` also performed bootstrap work.

After: `main.dart` only ensures bindings, installs safe error handlers, configures URL strategy, and runs `MasrofyBootstrapApp`. The bootstrap app owns storage initialization, migration, dependency configuration, and retry state.

## 5. Bootstrap Idempotency

Added `AppBootstrapController` with an active cached future. Rebuilds reuse the same attempt, while retry clears the active future and starts one deliberate new attempt.

Dependency registration remains idempotent through guarded GetIt registration helpers.

## 6. Startup Error Handling

Added safe global handlers:

- `FlutterError.onError`
- `PlatformDispatcher.instance.onError`
- `ErrorWidget.builder`

Startup failure UI is branded, localized, retryable, and does not show raw exception text to users.

## 7. Quarantine Security

Storage schema is now version `3`.

Quarantine moved to encrypted `storage_quarantine_v2`. Legacy plaintext `storage_quarantine_v1` is read only during migration, sanitized, copied into the encrypted store, then cleared after successful migration.

Sanitized quarantine records contain metadata such as source box, hashed record key, error category, migration version, record type, timestamp, and recovery flag. Raw record values are not retained.

## 8. Secure Storage Changes

Removed automatic production fallback to in-memory secure storage.

Added typed exceptions for secure value storage and Hive encryption key handling. If encrypted data exists and the key is missing, startup fails safely instead of generating a replacement key over existing encrypted boxes.

The in-memory secure store remains available only as an explicit test implementation.

## 9. Biometric Authentication

Added `BiometricAuthenticationService` abstraction with a `local_auth` implementation and in-memory test implementation.

App lock now:

- Checks device support/enrollment.
- Shows biometric settings only when available.
- Requires current PIN verification before enabling biometrics.
- Uses biometric unlock when enabled and available.
- Falls back to PIN on cancellation, lockout, unsupported platform, or plugin failure.

Android now uses `FlutterFragmentActivity` and declares `USE_BIOMETRIC`. iOS now includes `NSFaceIDUsageDescription`.

## 10. Transaction Validation

`SaveTransaction` now validates:

- Positive amount.
- Non-empty category id.
- Category existence.
- Category type matches transaction type.

Validation failures are typed and localized in the UI. Hidden categories remain usable for safe historical/edit flows through repository lookup with `includeHidden: true`.

## 11. Wallet Balance Readiness

`WalletBalancesCubit` now tracks first snapshots from wallet balances and transactions independently. It does not emit final ready summaries until both streams have produced initial values, preventing transient incorrect zero balances.

## 12. Offline Arabic PDF Support

Removed runtime Google Fonts usage from PDF generation.

Bundled local Noto fonts:

- `NotoSansArabic-Regular.ttf`
- `NotoSansArabic-Bold.ttf`
- `NotoSans-Regular.ttf`
- `NotoSans-Bold.ttf`
- `OFL.txt`

PDF export now loads fonts from assets and uses Arabic/Latin fallbacks offline.

## 13. Backup File Picker

Added `BackupFilePicker` abstraction and `PlatformBackupFilePicker` using `file_picker`.

Settings import now uses a file picker and bytes-based restore instead of manual file path entry. It validates extension, bytes, size, and backup format via existing restore validation. Cancelled selection is silent.

## 14. Platform Abstractions and Web Compatibility

Removed direct `dart:io` use from presentation import paths.

`LocalExportWriter` now uses conditional exports:

- IO writer for mobile/desktop.
- Web writer using browser download APIs.
- Stub fallback for unsupported platforms.

Backup import is platform-adapted through the picker abstraction.

## 15. Branding Assets

Original logo inspection:

- `logo1.jpg`: 2000x2000, RGB, no alpha, white/light background, contains wallet mark and text.
- `logo2.png`: 2000x2000, ARGB, alpha, transparent background, contains wallet mark and text.

The originals were not destructively modified.

### Branding Asset Table

| Asset | Original/Generated | Usage | Dimensions | Transparency | Notes |
| ----- | ------------------ | ----- | ---------: | ------------ | ----- |
| `assets/images/logos/logo1.jpg` | Original | Light-surface fallback | 2000x2000 | No | White-background logo with text |
| `assets/images/logos/logo2.png` | Original | Primary logo | 2000x2000 | Yes | Transparent logo with text |
| `assets/images/branding/masrofy_icon_foreground.png` | Generated | Android adaptive foreground and Android 12 splash | 1024x1024 | Yes | Icon-only crop to avoid wordmark clipping |
| `assets/images/branding/masrofy_launcher_icon.png` | Generated | Launcher icons, iOS icon source, desktop/web icons | 1024x1024 | No | Opaque icon source for platforms that disallow alpha |
| `assets/images/branding/masrofy_splash_logo.png` | Generated | Native/Flutter splash and brand UI | 1200x1200 | Yes | Full transparent logo |
| `web/icons/Icon-192.png` | Generated | Web manifest | 192x192 | No | Generated icon |
| `web/icons/Icon-512.png` | Generated | Web manifest | 512x512 | No | Generated icon |

## 16. Generated Branding Assets

Derived assets were generated from `logo2.png`:

- Icon-only foreground.
- Opaque launcher icon.
- Transparent splash logo.

`flutter_launcher_icons` generated Android, iOS, web, Windows, and macOS icons.

`flutter_native_splash` generated Android, Android 12, iOS, and web splash assets.

## 17. Application Name Changes

Visible app name is now `Masrofy` in localization and platform metadata.

Updated Android label, iOS display name, macOS product name, Windows resource metadata, Linux window title, web manifest, and web title.

### Platform Identity Table

| Platform | Visible Name | Identifier | Icon Updated | Splash Updated | Validation |
| -------- | ------------ | ---------- | ------------ | -------------- | ---------- |
| Android | Masrofy | `com.example.masrofy` | Yes | Yes | `flutter build apk --debug` passed |
| iOS | Masrofy | `$(PRODUCT_BUNDLE_IDENTIFIER)` / current project setting | Yes | Yes | Generated only; macOS build not run |
| Web | Masrofy | Manifest start URL `.` | Yes | Yes | `flutter build web` passed |
| Windows | Masrofy | Existing Windows runner binary identity | Yes | N/A | Generated icon; Windows app build not run |
| macOS | Masrofy | `com.example.masrofy` | Yes | N/A | Generated icon; macOS build not run |
| Linux | Masrofy | `com.example.masrofy` | Existing icon flow | N/A | Title updated; Linux build not run |

## 18. Launcher Icon Configuration

Added `flutter_launcher_icons` configuration in `pubspec.yaml`.

Android adaptive icon uses:

- Foreground: `assets/images/branding/masrofy_icon_foreground.png`
- Background: theme-aligned light color

iOS uses an opaque source to avoid alpha-channel icon issues.

## 19. Native Splash Configuration

Added `flutter_native_splash` configuration in `pubspec.yaml`.

Generated:

- Android pre-12 launch backgrounds.
- Android 12 splash images/styles.
- iOS LaunchScreen assets.
- Web splash assets/CSS.

## 20. Flutter Animated Splash

The Flutter bootstrap screen now displays Masrofy branding while storage and dependencies initialize. It avoids fixed delays and keeps startup tied to real bootstrap completion.

## 21. Onboarding Design

Added a four-page onboarding flow:

1. Welcome/local-first tracking.
2. Budgets and reports.
3. Privacy and app lock.
4. Backup and export.

It uses existing design tokens, theme extension colors, Material buttons, page indicators, semantic headings, and reduced-motion support.

## 22. Onboarding Persistence and Migration

Added `onboardingCompleted` to `AppSettingsStore` and safe settings backup snapshots.

Fresh installs default to onboarding incomplete. Existing installations are migrated to completed unless an explicit value already exists. Delete-all-data restores settings defaults without forcing onboarding again.

Settings includes a preview route to replay onboarding without changing first-run completion state.

## 23. App Lock and Onboarding Ordering

Final order:

1. Native splash.
2. Flutter bootstrap splash.
3. Startup failure or success.
4. Onboarding when required.
5. App lock when required.
6. Main app.

Existing users are migrated past onboarding before app lock, so locked existing data is not exposed through onboarding.

## 24. Localization

Added English and Arabic strings for onboarding, biometrics, backup picker, validation, settings preview, and About UI. Regenerated `lib/l10n/generated/*`.

Arabic `appName` now resolves to `Masrofy`.

## 25. Accessibility

Added semantic logo labels, page indicator labels, semantic headings on onboarding titles, button labels, reduced-motion handling, RTL/LTR localization support, and minimum Material touch targets.

## 26. Android Changes

- `MainActivity` extends `FlutterFragmentActivity`.
- Added `USE_BIOMETRIC`.
- Label set to `Masrofy`.
- Launcher icons generated.
- Native splash and Android 12 splash generated.
- Debug APK build passed.

## 27. iOS Changes

- Display name uses `Masrofy`.
- Added Face ID usage description.
- App icons regenerated from an opaque source.
- Launch screen assets regenerated.

iOS build was not run because this validation environment is Windows, not macOS.

## 28. Web Changes

- Manifest name/short name/description/colors updated.
- Web icons regenerated.
- Web splash assets generated.
- Conditional export writer supports browser downloads.
- `flutter build web` passed with upstream wasm dry-run warnings from `image`.

## 29. Windows, macOS, and Linux Changes

- Windows resource metadata and icon updated.
- macOS product name, icons, and generated plugin registrant updated.
- Linux window title updated to `Masrofy`.

## 30. Dependencies Added or Removed

Added:

- `local_auth`: real biometric authentication.
- `file_picker`: backup import file selection.
- `flutter_launcher_icons`: generated launcher icons.
- `flutter_native_splash`: generated native splash assets.

`file_picker` was set to `10.3.7` because the initially resolved `3.0.4` lacked an Android namespace and failed AGP configuration.

No notification, Firebase, ads, subscription, analytics, cloud sync, or auth-backend packages were added.

## 31. Storage Schema and Migration Changes

- `StorageSchema.currentVersion` is now `3`.
- Added encrypted quarantine `storage_quarantine_v2`.
- Preserved legacy quarantine `storage_quarantine_v1` for controlled migration.
- Existing encrypted financial boxes and legacy migration paths are preserved.
- Existing encrypted data with missing key fails closed.

## 32. Tests Added

Added or updated tests for:

- Storage encryption fail-closed behavior.
- Quarantine migration sanitization.
- Transaction category validation.
- App lock biometric flow.
- App settings onboarding persistence.
- Wallet balance readiness.
- Onboarding navigation.
- Updated backup schema/settings snapshot.
- Updated settings/history/widget harnesses.

## 33. Integration Tests

Added `integration_test/onboarding_flow_test.dart`.

Verified:

- Onboarding renders.
- Skip completes first-run onboarding flow.

`flutter test integration_test` passed after Android build/install.

## 34. Commands Executed

Key commands run:

- `git status --short --untracked-files=all`
- `git branch --show-current`
- `git rev-parse HEAD`
- `flutter --version`
- `dart --version`
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter gen-l10n`
- `dart run flutter_launcher_icons`
- `dart run flutter_native_splash:create`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter pub run build_runner build --delete-conflicting-outputs`
- `flutter test integration_test`
- `flutter build apk --debug`
- `flutter build web`
- `dart format lib test integration_test`

## 35. Analysis and Test Results

### Test Results Table

| Command | Result | Test Count | Warnings | Notes |
| ------- | ------ | ---------: | -------- | ----- |
| `flutter analyze` | Passed | 0 issues | None | Final post-format run passed |
| `flutter test` | Passed | 119 | None | Final post-format run passed |
| `flutter test integration_test` | Passed | 1 | Java source/target 8 warnings; Kotlin daemon incremental-cache messages before fallback | APK built, installed, and test passed |
| `dart run build_runner build --delete-conflicting-outputs` | Failed | N/A | Build-hook tooling blocker | Dart beta reports: `dart compile` does not support build hooks; package `objective_c` |
| `flutter pub run build_runner build --delete-conflicting-outputs` | Failed | N/A | Same build-hook tooling blocker | Same `objective_c` build-hook issue |

## 36. Build Results

- `flutter build apk --debug`: passed, produced `build\app\outputs\flutter-apk\app-debug.apk`.
- `flutter build web`: passed, produced `build\web`.
- `flutter build ios --debug --no-codesign`: not run; macOS required.

Web build warnings:

- Flutter wasm dry run reported upstream `image 4.3.0` lint incompatibilities. Standard web build still passed.

## 37. Modified Files

### Files Table

| File | Change | Reason | Risk |
| ---- | ------ | ------ | ---- |
| `lib/main.dart` | Simplified startup and error handlers | Remove duplicate initialization | Medium |
| `lib/app/masrofy_bootstrap_app.dart` | Bootstrap controller, branded splash, retry | Idempotent startup | Medium |
| `lib/app/masrofy_app.dart` | Onboarding/app-lock ordering | First-run flow | Medium |
| `lib/di/service_locator.dart` | New services and safer settings store | Security/platform abstractions | Medium |
| `lib/core/storage/*` | Schema v3, encrypted quarantine, fail-closed keys | Storage security | High |
| `lib/core/security/*` | Secure store exceptions and biometrics | Security | High |
| `lib/core/settings/app_settings_store.dart` | Onboarding persistence | First-run migration | Medium |
| `lib/domain/usecases/transactions/save_transaction.dart` | Category validation | Data integrity | Medium |
| `lib/presentation/cubits/*` | Biometrics, onboarding, wallet readiness | UI state correctness | Medium |
| `lib/presentation/screens/settings/settings_screen.dart` | File picker, About, biometrics, onboarding preview | UX/platform readiness | Medium |
| `lib/presentation/widgets/transactions/add_transaction_sheet.dart` | Validation message mapping, responsive dropdown | Validation and layout | Low |
| `lib/data/export/report_pdf_exporter.dart` | Local fonts | Offline Arabic PDF | Medium |
| `pubspec.yaml` and `pubspec.lock` | Dependencies/assets/fonts/generation config | Required packages/assets | Medium |
| Platform folders | Icons, splash, metadata | Branding/platform identity | Medium |
| Tests | Updated/added coverage | Regression protection | Low |

## 38. Created Files

Created source files include:

- `lib/core/branding/brand_assets.dart`
- `lib/core/security/biometric_authentication_service.dart`
- `lib/data/backup/backup_file_picker.dart`
- `lib/data/export/local_export_writer_io.dart`
- `lib/data/export/local_export_writer_web.dart`
- `lib/data/export/local_export_writer_stub.dart`
- `lib/presentation/screens/onboarding/onboarding_screen.dart`
- `integration_test/onboarding_flow_test.dart`
- `test/presentation/cubits/wallets/wallet_balances_cubit_test.dart`
- `test/presentation/screens/onboarding/onboarding_screen_test.dart`
- `MASROFY_STABILIZATION_BRANDING_ONBOARDING_REPORT.md`

Created asset files include:

- `assets/images/branding/*`
- `assets/fonts/noto/*`
- Generated native/web icon and splash files.

## 39. Deleted Files

No files were intentionally deleted by this implementation.

The following deletions were already present in the initial working tree and were preserved:

- `MASROFY_UI_UX_IMPLEMENTATION_REPORT.md`
- `codex_flutter_full_review_prompt.md`
- `codex_ui_ux_deep_enhancement_prompt.md`

## 40. Generated Files

Generated by tooling:

- `lib/l10n/generated/*`
- Android launcher and splash resources.
- iOS app icon and launch image resources.
- macOS app icon resources.
- Windows icon resources.
- Web icons and splash resources.
- Plugin registrants for desktop platforms.

## 41. Existing User Compatibility

Existing encrypted boxes are preserved. Existing installations are detected from metadata, encrypted boxes, or legacy boxes and migrated to `onboardingCompleted = true` when no explicit value exists.

The missing encryption key path fails closed and does not overwrite encrypted data.

Backup safe settings include onboarding completion and continue excluding PINs, encryption keys, and secrets.

## 42. Manual Verification Checklist

Manual checks still recommended:

- Android native splash on a real device.
- Android 12 splash icon mask.
- Launcher icon masks across OEM launchers.
- App name display on installed Android/iOS apps.
- Real biometric prompt and cancellation/lockout.
- Face ID prompt copy on iOS.
- Backup picker on Android, iOS, desktop, and web.
- Arabic PDF visual rendering with real user-length notes.
- Large text and screen reader traversal.
- Store listing icon/screenshot review.

## 43. Remaining External Requirements

1. Production Android application ID.
2. Production Apple bundle identifier.
3. Android release keystore.
4. Apple signing and provisioning.
5. Real-device biometric testing.
6. Store icon/screenshot review.
7. macOS/iOS no-codesign build validation on a macOS machine.

## 44. Known Limitations

- `build_runner` is blocked in this Dart beta environment by transitive `objective_c` build hooks from platform dependencies. Both Dart and Flutter wrappers fail before builders run.
- iOS build was not executed because this environment is Windows.
- Integration coverage currently includes onboarding; the brief's larger integration matrix remains a future expansion.
- WebAssembly dry run reports upstream `image` package incompatibilities, but standard `flutter build web` passes.
- Production bundle identifiers and signing credentials are external release tasks.

## 45. Final Go/No-Go Assessment

Development readiness: Go.

Android debug readiness: Go for debug validation.

Web readiness: Go for standard web build.

iOS release readiness: No-Go until macOS build and signing validation.

Store release readiness: No-Go until production identifiers, signing, keystore, real-device biometric checks, and store assets are completed.
