import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/branding/brand_assets.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../data/backup/backup_file_picker.dart';
import '../../../data/backup/backup_restore_service.dart';
import '../../../data/export/data_export_service.dart';
import '../../../di/service_locator.dart';
import '../../../domain/entities/report_filter.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/reports/build_report.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../routing/app_router.dart';
import '../../cubits/security/app_lock_cubit.dart';
import '../../cubits/security/app_lock_state.dart';
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
                      BlocBuilder<AppLockCubit, AppLockState>(
                        builder: (context, appLockState) {
                          return _SettingsSection(
                            title: l10n.privacySecuritySectionTitle,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  secondary: const Icon(
                                    Icons.visibility_off_outlined,
                                  ),
                                  title: Text(l10n.hideFinancialAmountsTitle),
                                  subtitle: Text(
                                    l10n.hideFinancialAmountsSubtitle,
                                  ),
                                  value: settings.hideFinancialAmounts,
                                  onChanged: (value) {
                                    context
                                        .read<AppSettingsCubit>()
                                        .setHideFinancialAmounts(value);
                                  },
                                ),
                              ),
                              const Divider(height: AppSpacing.md),
                              if (!appLockState.isEnabled)
                                _SettingsActionTile(
                                  key: const ValueKey(
                                    'settings-enable-app-lock-tile',
                                  ),
                                  icon: Icons.lock_outline,
                                  title: l10n.appLockEnableTitle,
                                  subtitle: l10n.appLockEnableSubtitle,
                                  onTap: () => _enableAppLock(context),
                                )
                              else ...[
                                _SettingsActionTile(
                                  key: const ValueKey(
                                    'settings-change-pin-tile',
                                  ),
                                  icon: Icons.pin_outlined,
                                  title: l10n.appLockChangePinTitle,
                                  subtitle: l10n.appLockChangePinSubtitle,
                                  onTap: () => _changeAppLockPin(context),
                                ),
                                const Divider(height: AppSpacing.md),
                                if (appLockState
                                    .biometricAvailability
                                    .isAvailable) ...[
                                  Material(
                                    color: Colors.transparent,
                                    child: SwitchListTile(
                                      key: const ValueKey(
                                        'settings-biometric-switch',
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      secondary: const Icon(Icons.fingerprint),
                                      title: Text(
                                        l10n.appLockBiometricEnableTitle,
                                      ),
                                      subtitle: Text(
                                        l10n.appLockBiometricEnableSubtitle,
                                      ),
                                      value: appLockState
                                          .lockStatus
                                          .biometricEnabled,
                                      onChanged: (value) {
                                        _setBiometricUnlock(context, value);
                                      },
                                    ),
                                  ),
                                  const Divider(height: AppSpacing.md),
                                ],
                                _SettingsActionTile(
                                  key: const ValueKey(
                                    'settings-disable-app-lock-tile',
                                  ),
                                  icon: Icons.lock_open_outlined,
                                  title: l10n.appLockDisableTitle,
                                  subtitle: l10n.appLockDisableSubtitle,
                                  onTap: () => _disableAppLock(context),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.localPrivacyExplanation,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
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
                      const SizedBox(height: AppSpacing.xs),
                      _SettingsTile(
                        key: const ValueKey('settings-onboarding-tile'),
                        icon: Icons.flag_outlined,
                        title: l10n.settingsViewOnboardingTitle,
                        subtitle: l10n.settingsViewOnboardingSubtitle,
                        onTap: () => context.push(
                          AppRoutes.onboardingPreview,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsSection(
                        title: l10n.settingsDataManagementTitle,
                        children: [
                          _SettingsActionTile(
                            key: const ValueKey('settings-export-backup-tile'),
                            icon: Icons.backup_outlined,
                            title: l10n.settingsExportBackupTitle,
                            subtitle: l10n.settingsExportBackupSubtitle,
                            onTap: () => _exportBackup(context),
                          ),
                          const Divider(height: AppSpacing.md),
                          _SettingsActionTile(
                            key: const ValueKey('settings-import-backup-tile'),
                            icon: Icons.restore_page_outlined,
                            title: l10n.settingsImportBackupTitle,
                            subtitle: l10n.settingsImportBackupSubtitle,
                            onTap: () => _importBackup(context),
                          ),
                          const Divider(height: AppSpacing.md),
                          _SettingsActionTile(
                            key: const ValueKey(
                              'settings-export-transactions-tile',
                            ),
                            icon: Icons.table_chart_outlined,
                            title: l10n.settingsExportAllTransactionsTitle,
                            subtitle:
                                l10n.settingsExportAllTransactionsSubtitle,
                            onTap: () => _exportAllTransactions(context),
                          ),
                          const Divider(height: AppSpacing.md),
                          _SettingsActionTile(
                            key: const ValueKey('settings-export-report-tile'),
                            icon: Icons.picture_as_pdf_outlined,
                            title: l10n.settingsExportCurrentReportTitle,
                            subtitle: l10n.settingsExportCurrentReportSubtitle,
                            onTap: () => _exportCurrentMonthReport(context),
                          ),
                          const Divider(height: AppSpacing.md),
                          _SettingsActionTile(
                            key: const ValueKey('settings-delete-data-tile'),
                            icon: Icons.delete_forever_outlined,
                            title: l10n.settingsDeleteAllDataTitle,
                            subtitle: l10n.settingsDeleteAllDataSubtitle,
                            onTap: () => _deleteAllLocalData(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.settingsStoragePrivacyNote,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsSection(
                        title: l10n.settingsAboutTitle,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                                child: Image.asset(
                                  BrandAssets.primaryLogo,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.appName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      l10n.settingsAboutDescription,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.localPrivacyExplanation,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
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

  Future<void> _exportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final file = await serviceLocator<BackupRestoreService>()
          .buildBackupFile();
      final path = await serviceLocator<DataExportService>().save(file);
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, l10n.exportSavedMessage(path));
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.exportFailedMessage);
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    PickedBackupFile? pickedFile;
    try {
      pickedFile = await serviceLocator<BackupFilePicker>().pickBackupFile();
    } on BackupFilePickerException {
      if (context.mounted) {
        _showSnackBar(context, l10n.backupImportInvalidFile);
      }
      return;
    }
    if (pickedFile == null || !context.mounted) {
      return;
    }
    final mode = await showDialog<BackupImportMode>(
      context: context,
      builder: (_) => _BackupImportModeDialog(
        localizations: l10n,
        fileName: pickedFile!.name,
      ),
    );
    if (mode == null || !context.mounted) {
      return;
    }
    if (mode == BackupImportMode.replace) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => _DangerConfirmDialog(
          title: l10n.backupImportDialogTitle,
          body: l10n.backupImportReplaceWarning,
          hintText: l10n.deleteAllDataConfirmHint,
          actionLabel: l10n.commonConfirm,
          localizations: l10n,
        ),
      );
      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    try {
      await serviceLocator<BackupRestoreService>().restoreBackupBytes(
        pickedFile.bytes,
        mode: mode,
      );
      if (!context.mounted) {
        return;
      }
      context.read<AppSettingsCubit>().reload();
      _showSnackBar(context, l10n.backupImportSuccess);
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.backupImportFailed);
      }
    }
  }

  Future<void> _exportAllTransactions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    try {
      final transactions = await serviceLocator<TransactionRepository>()
          .getTransactions();
      final categories = await serviceLocator<CategoryRepository>()
          .getCategories(includeHidden: true);
      final file = serviceLocator<DataExportService>().buildTransactionsExcel(
        transactions: transactions,
        categoriesById: {
          for (final category in categories) category.id: category,
        },
        localeName: localeName,
      );
      final path = await serviceLocator<DataExportService>().save(file);
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, l10n.exportSavedMessage(path));
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.exportFailedMessage);
      }
    }
  }

  Future<void> _exportCurrentMonthReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    try {
      final transactions = await serviceLocator<TransactionRepository>()
          .getTransactions();
      final categories = await serviceLocator<CategoryRepository>()
          .getCategories(includeHidden: true);
      final report = serviceLocator<BuildReport>()(
        transactions: transactions,
        filter: const ReportFilter(periodType: ReportPeriodType.thisMonth),
      );
      final dateFormat = intl.DateFormat.yMMMd(localeName);
      final file = await serviceLocator<DataExportService>().buildReportPdf(
        report: report,
        categoriesById: {
          for (final category in categories) category.id: category,
        },
        title: l10n.reportsTitle,
        dateRangeLabel: l10n.reportsDateRange(
          dateFormat.format(report.range.start),
          dateFormat.format(
            report.range.endExclusive.subtract(const Duration(days: 1)),
          ),
        ),
        localeName: localeName,
      );
      await serviceLocator<DataExportService>().sharePdf(file);
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.exportFailedMessage);
      }
    }
  }

  Future<void> _deleteAllLocalData(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DangerConfirmDialog(
        title: l10n.deleteAllDataDialogTitle,
        body: l10n.deleteAllDataDialogBody,
        hintText: l10n.deleteAllDataConfirmHint,
        actionLabel: l10n.commonDelete,
        localizations: l10n,
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await serviceLocator<BackupRestoreService>().deleteAllLocalData();
      if (!context.mounted) {
        return;
      }
      context.read<AppSettingsCubit>().reload();
      _showSnackBar(context, l10n.deleteAllDataSuccess);
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.deleteAllDataFailed);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _enableAppLock(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => _PinSetupDialog(localizations: l10n),
    );
    if (pin == null || !context.mounted) {
      return;
    }
    try {
      await context.read<AppLockCubit>().setupPin(pin);
      if (context.mounted) {
        _showSnackBar(context, l10n.appLockEnabledMessage);
      }
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.appLockOperationFailed);
      }
    }
  }

  Future<void> _changeAppLockPin(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final request = await showDialog<_PinChangeRequest>(
      context: context,
      builder: (_) => _PinSetupDialog(
        localizations: l10n,
        requireCurrentPin: true,
      ),
    );
    if (request == null || !context.mounted) {
      return;
    }
    try {
      await context.read<AppLockCubit>().changePin(
        currentPin: request.currentPin,
        newPin: request.newPin,
      );
      if (context.mounted) {
        _showSnackBar(context, l10n.appLockPinChangedMessage);
      }
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.appLockOperationFailed);
      }
    }
  }

  Future<void> _disableAppLock(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => _CurrentPinDialog(localizations: l10n),
    );
    if (pin == null || !context.mounted) {
      return;
    }
    try {
      await context.read<AppLockCubit>().disable(currentPin: pin);
      if (context.mounted) {
        _showSnackBar(context, l10n.appLockDisabledMessage);
      }
    } on Object {
      if (context.mounted) {
        _showSnackBar(context, l10n.appLockOperationFailed);
      }
    }
  }

  Future<void> _setBiometricUnlock(
    BuildContext context,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context);
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => _CurrentPinDialog(
        title: enabled
            ? l10n.appLockBiometricEnableTitle
            : l10n.appLockBiometricDisableTitle,
        localizations: l10n,
      ),
    );
    if (pin == null || !context.mounted) {
      return;
    }
    final success = await context.read<AppLockCubit>().setBiometricEnabled(
      enabled: enabled,
      currentPin: pin,
    );
    if (!context.mounted) {
      return;
    }
    _showSnackBar(
      context,
      success
          ? enabled
                ? l10n.appLockBiometricEnabledMessage
                : l10n.appLockBiometricDisabledMessage
          : l10n.appLockOperationFailed,
    );
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
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: AppRadii.card,
        border: Border.all(color: colors.cardBorder),
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
    final theme = Theme.of(context).extension<MasrofyThemeExtension>()!;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: _SettingsIcon(icon: icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: onTap == null ? null : Icon(_chevronIcon(context)),
        onTap: onTap,
        tileColor: theme.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: theme.cardBorder),
        ),
      ),
    );
  }

  IconData _chevronIcon(BuildContext context) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => Icons.chevron_left,
      TextDirection.ltr => Icons.chevron_right,
    };
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MasrofyThemeExtension>()!;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _SettingsIcon(icon: icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(_chevronIcon(context)),
        onTap: onTap,
        tileColor: theme.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: theme.cardBorder),
        ),
      ),
    );
  }

  IconData _chevronIcon(BuildContext context) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => Icons.chevron_left,
      TextDirection.ltr => Icons.chevron_right,
    };
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppRadii.card,
      ),
      child: SizedBox.square(
        dimension: 42,
        child: Icon(icon, color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}

class _PinChangeRequest {
  const _PinChangeRequest({
    required this.currentPin,
    required this.newPin,
  });

  final String currentPin;
  final String newPin;
}

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog({
    required this.localizations,
    this.requireCurrentPin = false,
  });

  final AppLocalizations localizations;
  final bool requireCurrentPin;

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool get _isValid {
    final pin = _pinController.text.trim();
    final current = _currentController.text.trim();
    return RegExp(r'^\d{4,8}$').hasMatch(pin) &&
        pin == _confirmController.text.trim() &&
        (!widget.requireCurrentPin || RegExp(r'^\d{4,8}$').hasMatch(current));
  }

  @override
  void dispose() {
    _currentController.dispose();
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.localizations;
    return AlertDialog(
      title: Text(
        widget.requireCurrentPin
            ? l10n.appLockChangePinTitle
            : l10n.appLockEnableTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.requireCurrentPin) ...[
            TextField(
              controller: _currentController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.appLockCurrentPinLabel,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.appLockPinLabel,
              helperText: l10n.appLockPinHelper,
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _confirmController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.appLockConfirmPinLabel,
              prefixIcon: const Icon(Icons.verified_user_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isValid
              ? () {
                  final pin = _pinController.text.trim();
                  if (widget.requireCurrentPin) {
                    Navigator.of(context).pop(
                      _PinChangeRequest(
                        currentPin: _currentController.text.trim(),
                        newPin: pin,
                      ),
                    );
                  } else {
                    Navigator.of(context).pop(pin);
                  }
                }
              : null,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

class _CurrentPinDialog extends StatefulWidget {
  const _CurrentPinDialog({
    required this.localizations,
    this.title,
  });

  final AppLocalizations localizations;
  final String? title;

  @override
  State<_CurrentPinDialog> createState() => _CurrentPinDialogState();
}

class _CurrentPinDialogState extends State<_CurrentPinDialog> {
  final TextEditingController _controller = TextEditingController();

  bool get _isValid => RegExp(r'^\d{4,8}$').hasMatch(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.localizations;
    return AlertDialog(
      title: Text(widget.title ?? l10n.appLockDisableTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: l10n.appLockCurrentPinLabel,
          prefixIcon: const Icon(Icons.lock_outline),
        ),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isValid
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}

class _BackupImportModeDialog extends StatefulWidget {
  const _BackupImportModeDialog({
    required this.localizations,
    required this.fileName,
  });

  final AppLocalizations localizations;
  final String fileName;

  @override
  State<_BackupImportModeDialog> createState() =>
      _BackupImportModeDialogState();
}

class _BackupImportModeDialogState extends State<_BackupImportModeDialog> {
  BackupImportMode _mode = BackupImportMode.merge;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.localizations;

    return AlertDialog(
      title: Text(l10n.backupImportDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.backupSelectedFile(widget.fileName)),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<BackupImportMode>(
            initialValue: _mode,
            decoration: InputDecoration(
              labelText: l10n.backupImportModeLabel,
              prefixIcon: const Icon(Icons.merge_type_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: BackupImportMode.merge,
                child: Text(l10n.backupImportMerge),
              ),
              DropdownMenuItem(
                value: BackupImportMode.replace,
                child: Text(l10n.backupImportReplace),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _mode = value);
              }
            },
          ),
          if (_mode == BackupImportMode.replace) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.backupImportReplaceWarning,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_mode),
          icon: const Icon(Icons.restore_outlined),
          label: Text(l10n.backupImportAction),
        ),
      ],
    );
  }
}

class _DangerConfirmDialog extends StatefulWidget {
  const _DangerConfirmDialog({
    required this.title,
    required this.body,
    required this.hintText,
    required this.actionLabel,
    required this.localizations,
  });

  final String title;
  final String body;
  final String hintText;
  final String actionLabel;
  final AppLocalizations localizations;

  @override
  State<_DangerConfirmDialog> createState() => _DangerConfirmDialogState();
}

class _DangerConfirmDialogState extends State<_DangerConfirmDialog> {
  final TextEditingController _controller = TextEditingController();

  bool get _isConfirmed => _controller.text.trim() == 'DELETE';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.body),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.hintText,
              prefixIcon: const Icon(Icons.warning_amber_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(widget.localizations.commonCancel),
        ),
        FilledButton(
          onPressed: _isConfirmed
              ? () => Navigator.of(context).pop(true)
              : null,
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}
