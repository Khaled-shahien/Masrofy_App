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
    await cubit.setHideFinancialAmounts(true);

    expect(cubit.state.locale, const Locale('en'));
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.hideFinancialAmounts, isTrue);
    expect(cubit.state.shouldMaskFinancialAmounts, isTrue);
    expect(store.localeCode, 'en');
    expect(store.themeMode, ThemeMode.dark);
    expect(store.hideFinancialAmounts, isTrue);

    await cubit.close();
  });

  test('reloads settings after an external restore', () async {
    final store = InMemoryAppSettingsStore();
    final cubit = AppSettingsCubit(store: store);

    await store.restoreSafeSnapshot(
      const AppSettingsSnapshot(
        localeCode: 'en',
        themeMode: ThemeMode.light,
        hideFinancialAmounts: true,
      ),
    );
    cubit.reload();

    expect(cubit.state.locale, const Locale('en'));
    expect(cubit.state.themeMode, ThemeMode.light);
    expect(cubit.state.hideFinancialAmounts, isTrue);

    await cubit.close();
  });

  test('temporarily reveals hidden financial amounts', () async {
    final store = InMemoryAppSettingsStore();
    final cubit = AppSettingsCubit(store: store);
    await cubit.setHideFinancialAmounts(true);

    cubit.toggleFinancialAmountReveal(
      duration: const Duration(milliseconds: 10),
    );

    expect(cubit.state.revealFinancialAmounts, isTrue);
    expect(cubit.state.shouldMaskFinancialAmounts, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.revealFinancialAmounts, isFalse);
    expect(cubit.state.shouldMaskFinancialAmounts, isTrue);

    await cubit.close();
  });
}
