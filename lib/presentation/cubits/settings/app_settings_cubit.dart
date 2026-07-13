import 'dart:async';

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
    required this.hideFinancialAmounts,
    required this.onboardingCompleted,
    this.revealFinancialAmounts = false,
  });

  /// Current application locale.
  final Locale locale;

  /// Current application theme mode.
  final ThemeMode themeMode;

  /// Whether financial values should be hidden by default.
  final bool hideFinancialAmounts;

  /// Whether first-run onboarding has been completed or skipped.
  final bool onboardingCompleted;

  /// Whether hidden financial values are temporarily visible.
  final bool revealFinancialAmounts;

  bool get shouldMaskFinancialAmounts =>
      hideFinancialAmounts && !revealFinancialAmounts;

  AppSettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? hideFinancialAmounts,
    bool? onboardingCompleted,
    bool? revealFinancialAmounts,
  }) {
    return AppSettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      hideFinancialAmounts: hideFinancialAmounts ?? this.hideFinancialAmounts,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      revealFinancialAmounts:
          revealFinancialAmounts ?? this.revealFinancialAmounts,
    );
  }

  @override
  List<Object> get props => [
    locale,
    themeMode,
    hideFinancialAmounts,
    onboardingCompleted,
    revealFinancialAmounts,
  ];
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
          hideFinancialAmounts: store.hideFinancialAmounts,
          onboardingCompleted: store.onboardingCompleted,
        ),
      );

  final AppSettingsStore _store;
  Timer? _revealTimer;

  /// Refreshes preference state after an external restore/reset operation.
  void reload() {
    emit(
      AppSettingsState(
        locale: Locale(_store.localeCode),
        themeMode: _store.themeMode,
        hideFinancialAmounts: _store.hideFinancialAmounts,
        onboardingCompleted: _store.onboardingCompleted,
        revealFinancialAmounts: false,
      ),
    );
  }

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

  /// Enables or disables financial amount masking.
  Future<void> setHideFinancialAmounts(bool hideFinancialAmounts) async {
    if (hideFinancialAmounts == state.hideFinancialAmounts) {
      return;
    }
    _cancelRevealTimer();
    emit(
      state.copyWith(
        hideFinancialAmounts: hideFinancialAmounts,
        revealFinancialAmounts: false,
      ),
    );
    await _store.saveHideFinancialAmounts(hideFinancialAmounts);
  }

  /// Marks onboarding as complete after Skip/Get Started.
  Future<void> completeOnboarding() async {
    if (state.onboardingCompleted) {
      return;
    }
    emit(state.copyWith(onboardingCompleted: true));
    await _store.saveOnboardingCompleted(true);
  }

  /// Reveals hidden amounts temporarily, or hides them immediately if visible.
  void toggleFinancialAmountReveal({
    Duration duration = const Duration(seconds: 30),
  }) {
    if (!state.hideFinancialAmounts) {
      return;
    }
    if (state.revealFinancialAmounts) {
      _cancelRevealTimer();
      emit(state.copyWith(revealFinancialAmounts: false));
      return;
    }
    emit(state.copyWith(revealFinancialAmounts: true));
    _cancelRevealTimer();
    _revealTimer = Timer(duration, () {
      if (!isClosed) {
        emit(state.copyWith(revealFinancialAmounts: false));
      }
    });
  }

  void _cancelRevealTimer() {
    _revealTimer?.cancel();
    _revealTimer = null;
  }

  @override
  Future<void> close() {
    _cancelRevealTimer();
    return super.close();
  }
}
