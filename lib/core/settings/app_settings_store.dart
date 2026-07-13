import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Safe, user-facing settings that may be included in a local backup.
class AppSettingsSnapshot {
  /// Creates a settings snapshot suitable for backup and restore.
  const AppSettingsSnapshot({
    required this.localeCode,
    required this.themeMode,
    required this.hideFinancialAmounts,
    required this.onboardingCompleted,
  });

  /// Default preferences used after a full local reset.
  const AppSettingsSnapshot.defaults()
    : localeCode = 'ar',
      themeMode = ThemeMode.system,
      hideFinancialAmounts = false,
      onboardingCompleted = true;

  /// The preferred locale language code.
  final String localeCode;

  /// The preferred theme mode.
  final ThemeMode themeMode;

  /// Whether user-facing financial amounts should be hidden by default.
  final bool hideFinancialAmounts;

  /// Whether first-run onboarding was completed or intentionally skipped.
  final bool onboardingCompleted;

  /// Decodes and validates a safe settings snapshot.
  factory AppSettingsSnapshot.fromJson(Map<String, dynamic> json) {
    final localeCode = json['localeCode'];
    final themeMode = json['themeMode'];
    if (localeCode is! String || localeCode.isEmpty) {
      throw const FormatException('Invalid settings locale.');
    }
    if (themeMode is! String) {
      throw const FormatException('Invalid settings theme mode.');
    }
    return AppSettingsSnapshot(
      localeCode: localeCode,
      themeMode: _themeModeFromNameStrict(themeMode),
      hideFinancialAmounts: json['hideFinancialAmounts'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? true,
    );
  }

  /// Encodes only safe settings fields.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'localeCode': localeCode,
      'themeMode': themeMode.name,
      'hideFinancialAmounts': hideFinancialAmounts,
      'onboardingCompleted': onboardingCompleted,
    };
  }
}

/// Stores user-facing application preferences.
abstract class AppSettingsStore {
  /// Reads the preferred locale code.
  String get localeCode;

  /// Reads the preferred theme mode.
  ThemeMode get themeMode;

  /// Reads whether financial amounts should be hidden.
  bool get hideFinancialAmounts;

  /// Reads whether first-run onboarding is complete.
  bool get onboardingCompleted;

  /// Persists the preferred locale code.
  Future<void> saveLocaleCode(String localeCode);

  /// Persists the preferred theme mode.
  Future<void> saveThemeMode(ThemeMode themeMode);

  /// Persists whether financial amounts should be hidden.
  Future<void> saveHideFinancialAmounts(bool hideFinancialAmounts);

  /// Persists whether first-run onboarding is complete.
  Future<void> saveOnboardingCompleted(bool onboardingCompleted);

  /// Marks previous installations as already onboarded when the setting
  /// did not exist in older app versions.
  Future<void> migrateOnboardingState({
    required bool existingInstallation,
  });

  /// Reads the safe settings snapshot that may be backed up.
  AppSettingsSnapshot get safeSnapshot;

  /// Restores safe user-facing settings from a backup snapshot.
  Future<void> restoreSafeSnapshot(AppSettingsSnapshot snapshot);
}

/// Hive-backed implementation for user preferences.
class HiveAppSettingsStore implements AppSettingsStore {
  /// Creates a settings store backed by a Hive string box.
  const HiveAppSettingsStore(this._box);

  static const _localeKey = 'locale';
  static const _themeModeKey = 'themeMode';
  static const _hideFinancialAmountsKey = 'hideFinancialAmounts';
  static const _onboardingCompletedKey = 'onboardingCompleted';
  static const _defaultLocaleCode = 'ar';

  final Box<String> _box;

  @override
  String get localeCode {
    return _box.get(_localeKey, defaultValue: _defaultLocaleCode)!;
  }

  @override
  ThemeMode get themeMode {
    return _themeModeFromName(_box.get(_themeModeKey));
  }

  @override
  bool get hideFinancialAmounts {
    return _box.get(_hideFinancialAmountsKey) == 'true';
  }

  @override
  bool get onboardingCompleted {
    return _box.get(_onboardingCompletedKey) == 'true';
  }

  @override
  AppSettingsSnapshot get safeSnapshot {
    return AppSettingsSnapshot(
      localeCode: localeCode,
      themeMode: themeMode,
      hideFinancialAmounts: hideFinancialAmounts,
      onboardingCompleted: onboardingCompleted,
    );
  }

  @override
  Future<void> saveLocaleCode(String localeCode) {
    return _box.put(_localeKey, localeCode);
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) {
    return _box.put(_themeModeKey, themeMode.name);
  }

  @override
  Future<void> saveHideFinancialAmounts(bool hideFinancialAmounts) {
    return _box.put(_hideFinancialAmountsKey, hideFinancialAmounts.toString());
  }

  @override
  Future<void> saveOnboardingCompleted(bool onboardingCompleted) {
    return _box.put(_onboardingCompletedKey, onboardingCompleted.toString());
  }

  @override
  Future<void> migrateOnboardingState({
    required bool existingInstallation,
  }) async {
    if (_box.get(_onboardingCompletedKey) != null) {
      return;
    }
    if (existingInstallation) {
      await saveOnboardingCompleted(true);
    }
  }

  @override
  Future<void> restoreSafeSnapshot(AppSettingsSnapshot snapshot) async {
    await saveLocaleCode(snapshot.localeCode);
    await saveThemeMode(snapshot.themeMode);
    await saveHideFinancialAmounts(snapshot.hideFinancialAmounts);
    await saveOnboardingCompleted(snapshot.onboardingCompleted);
  }
}

/// In-memory preferences used when persistent storage is unavailable.
class InMemoryAppSettingsStore implements AppSettingsStore {
  String _localeCode = 'ar';
  ThemeMode _themeMode = ThemeMode.system;
  bool _hideFinancialAmounts = false;
  bool _onboardingCompleted = false;
  bool _hasOnboardingValue = false;

  @override
  String get localeCode => _localeCode;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  bool get hideFinancialAmounts => _hideFinancialAmounts;

  @override
  bool get onboardingCompleted => _onboardingCompleted;

  @override
  AppSettingsSnapshot get safeSnapshot {
    return AppSettingsSnapshot(
      localeCode: localeCode,
      themeMode: themeMode,
      hideFinancialAmounts: hideFinancialAmounts,
      onboardingCompleted: onboardingCompleted,
    );
  }

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    _localeCode = localeCode;
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
  }

  @override
  Future<void> saveHideFinancialAmounts(bool hideFinancialAmounts) async {
    _hideFinancialAmounts = hideFinancialAmounts;
  }

  @override
  Future<void> saveOnboardingCompleted(bool onboardingCompleted) async {
    _onboardingCompleted = onboardingCompleted;
    _hasOnboardingValue = true;
  }

  @override
  Future<void> migrateOnboardingState({
    required bool existingInstallation,
  }) async {
    if (_hasOnboardingValue) {
      return;
    }
    if (existingInstallation) {
      _onboardingCompleted = true;
      _hasOnboardingValue = true;
    }
  }

  @override
  Future<void> restoreSafeSnapshot(AppSettingsSnapshot snapshot) async {
    _localeCode = snapshot.localeCode;
    _themeMode = snapshot.themeMode;
    _hideFinancialAmounts = snapshot.hideFinancialAmounts;
    _onboardingCompleted = snapshot.onboardingCompleted;
    _hasOnboardingValue = true;
  }
}

ThemeMode _themeModeFromName(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

ThemeMode _themeModeFromNameStrict(String value) {
  return switch (value) {
    'system' => ThemeMode.system,
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => throw const FormatException('Invalid settings theme mode.'),
  };
}
