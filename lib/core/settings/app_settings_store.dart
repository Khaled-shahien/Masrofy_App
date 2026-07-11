import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Stores user-facing application preferences.
abstract class AppSettingsStore {
  /// Reads the preferred locale code.
  String get localeCode;

  /// Reads the preferred theme mode.
  ThemeMode get themeMode;

  /// Persists the preferred locale code.
  Future<void> saveLocaleCode(String localeCode);

  /// Persists the preferred theme mode.
  Future<void> saveThemeMode(ThemeMode themeMode);
}

/// Hive-backed implementation for user preferences.
class HiveAppSettingsStore implements AppSettingsStore {
  /// Creates a settings store backed by a Hive string box.
  const HiveAppSettingsStore(this._box);

  static const _localeKey = 'locale';
  static const _themeModeKey = 'themeMode';
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
  Future<void> saveLocaleCode(String localeCode) {
    return _box.put(_localeKey, localeCode);
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) {
    return _box.put(_themeModeKey, themeMode.name);
  }
}

/// In-memory preferences used when persistent storage is unavailable.
class InMemoryAppSettingsStore implements AppSettingsStore {
  String _localeCode = 'ar';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  String get localeCode => _localeCode;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    _localeCode = localeCode;
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
  }
}

ThemeMode _themeModeFromName(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
