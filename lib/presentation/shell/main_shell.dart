import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../cubits/settings/app_settings_cubit.dart';
import '../cubits/transactions/transactions_cubit.dart';
import '../widgets/transactions/add_transaction_sheet.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          BlocBuilder<AppSettingsCubit, AppSettingsState>(
            buildWhen: (previous, current) =>
                previous.hideFinancialAmounts != current.hideFinancialAmounts ||
                previous.revealFinancialAmounts !=
                    current.revealFinancialAmounts,
            builder: (context, settings) {
              if (!settings.hideFinancialAmounts) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: settings.revealFinancialAmounts
                    ? l10n.hideAmountsTooltip
                    : l10n.showAmountsTooltip,
                onPressed: context
                    .read<AppSettingsCubit>()
                    .toggleFinancialAmountReveal,
                icon: Icon(
                  settings.revealFinancialAmounts
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              );
            },
          ),
        ],
      ),
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final transactionsCubit = context.read<TransactionsCubit>();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => BlocProvider.value(
              value: transactionsCubit,
              child: const AddTransactionSheet(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addTransaction),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboardTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.historyTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l10n.reportsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.savings_outlined),
            selectedIcon: const Icon(Icons.savings),
            label: l10n.budgetsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }
}
