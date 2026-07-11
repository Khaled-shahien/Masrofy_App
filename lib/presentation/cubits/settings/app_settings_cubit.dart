import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/settings/app_settings_store.dart';

/// Immutable app preference state exposed to the widget tree.
class AppSettingsState extends Equatable {
  /// Creates application preference state.
  const AppSettingsState({
    required this.locale,
    required this.themeMode,
  });

  /// Current application locale.
  final Locale locale;

  /// Current application theme mode.
  final ThemeMode themeMode;

  AppSettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
  }) {
    return AppSettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [locale, themeMode];
}

/// Coordinates user-facing app preferences.
class AppSettingsCubit extends Cubit<AppSettingsState> {
  /// Creates the settings cubit from persisted preferences.
  AppSettingsCubit({required AppSettingsStore store})
    : _store = store,
      super(
        AppSettingsState(
          locale: Locale(store.localeCode),
          themeMode: store.themeMode,
        ),
      );

  final AppSettingsStore _store;

  /// Updates and persists the active locale.
  Future<void> setLocale(Locale locale) async {
    if (locale == state.locale) {
      return;
    }
    emit(state.copyWith(locale: locale));
    await _store.saveLocaleCode(locale.languageCode);
  }

  /// Updates and persists the theme mode.
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (themeMode == state.themeMode) {
      return;
    }
    emit(state.copyWith(themeMode: themeMode));
    await _store.saveThemeMode(themeMode);
  }
}
