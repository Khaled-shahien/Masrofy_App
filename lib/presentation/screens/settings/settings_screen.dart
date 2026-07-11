import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../routing/app_router.dart';
import '../../cubits/settings/app_settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settings) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final padding = responsivePagePadding(constraints);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.md,
                    padding.right,
                    AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      l10n.settingsTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: padding.left),
                  sliver: SliverList.list(
                    children: [
                      _SettingsSection(
                        title: l10n.languageSectionTitle,
                        children: [
                          SegmentedButton<String>(
                            selected: {settings.locale.languageCode},
                            onSelectionChanged: (value) {
                              _setLocale(context, value.first);
                            },
                            segments: [
                              ButtonSegment(
                                value: 'ar',
                                icon: const Icon(Icons.language),
                                label: Text(l10n.languageArabic),
                              ),
                              ButtonSegment(
                                value: 'en',
                                icon: const Icon(Icons.translate),
                                label: Text(l10n.languageEnglish),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsSection(
                        title: l10n.themeSectionTitle,
                        children: [
                          SegmentedButton<ThemeMode>(
                            selected: {settings.themeMode},
                            onSelectionChanged: (value) {
                              _setThemeMode(context, value.first);
                            },
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: const Icon(
                                  Icons.brightness_auto_outlined,
                                ),
                                label: Text(l10n.themeModeSystem),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: const Icon(Icons.light_mode_outlined),
                                label: Text(l10n.themeModeLight),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: const Icon(Icons.dark_mode_outlined),
                                label: Text(l10n.themeModeDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsTile(
                        key: const ValueKey('settings-wallet-balances-tile'),
                        icon: Icons.account_balance_wallet_outlined,
                        title: l10n.settingsWalletBalancesTitle,
                        subtitle: l10n.settingsWalletBalancesSubtitle,
                        onTap: () => context.push(AppRoutes.walletBalances),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _SettingsTile(
                        key: const ValueKey('settings-categories-tile'),
                        icon: Icons.category_outlined,
                        title: l10n.settingsCategoriesTitle,
                        subtitle: l10n.settingsCategoriesSubtitle,
                        onTap: () => context.push(AppRoutes.categories),
                      ),
                      SizedBox(height: padding.bottom),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _setLocale(BuildContext context, String? value) {
    if (value == null) {
      return;
    }
    context.read<AppSettingsCubit>().setLocale(Locale(value));
  }

  void _setThemeMode(BuildContext context, ThemeMode? value) {
    if (value == null) {
      return;
    }
    context.read<AppSettingsCubit>().setThemeMode(value);
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null ? null : Icon(_chevronIcon(context)),
      onTap: onTap,
      tileColor: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
    );
  }

  IconData _chevronIcon(BuildContext context) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => Icons.chevron_left,
      TextDirection.ltr => Icons.chevron_right,
    };
  }
}
