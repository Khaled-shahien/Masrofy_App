import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/settings/app_settings_store.dart';
import 'package:masrofy/presentation/cubits/settings/app_settings_cubit.dart';

void main() {
  test('starts from stored defaults and persists preference changes', () async {
    final store = InMemoryAppSettingsStore();
    final cubit = AppSettingsCubit(store: store);

    expect(cubit.state.locale, const Locale('ar'));
    expect(cubit.state.themeMode, ThemeMode.system);

    await cubit.setLocale(const Locale('en'));
    await cubit.setThemeMode(ThemeMode.dark);

    expect(cubit.state.locale, const Locale('en'));
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(store.localeCode, 'en');
    expect(store.themeMode, ThemeMode.dark);

    await cubit.close();
  });
}
