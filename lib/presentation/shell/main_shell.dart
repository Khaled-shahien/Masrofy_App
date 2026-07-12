import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_design_tokens.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final showNavigationRail = width >= AppBreakpoints.tablet;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: const [_PrivacyRevealButton()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!showNavigationRail) {
            return navigationShell;
          }
          return Row(
            children: [
              _AdaptiveNavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _goBranch,
                extended: constraints.maxWidth >= AppBreakpoints.desktop,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: navigationShell),
            ],
          );
        },
      ),
      floatingActionButton: _AddTransactionFab(extended: width >= 390),
      bottomNavigationBar: showNavigationRail
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              destinations: _navigationDestinations(l10n),
            ),
    );
  }
}

class _PrivacyRevealButton extends StatelessWidget {
  const _PrivacyRevealButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      buildWhen: (previous, current) =>
          previous.hideFinancialAmounts != current.hideFinancialAmounts ||
          previous.revealFinancialAmounts != current.revealFinancialAmounts,
      builder: (context, settings) {
        if (!settings.hideFinancialAmounts) {
          return const SizedBox.shrink();
        }
        final label = settings.revealFinancialAmounts
            ? l10n.hideAmountsTooltip
            : l10n.showAmountsTooltip;
        return Semantics(
          button: true,
          label: label,
          child: IconButton(
            tooltip: label,
            onPressed: context
                .read<AppSettingsCubit>()
                .toggleFinancialAmountReveal,
            icon: AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Icon(
                settings.revealFinancialAmounts
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                key: ValueKey(settings.revealFinancialAmounts),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddTransactionFab extends StatefulWidget {
  const _AddTransactionFab({required this.extended});

  final bool extended;

  @override
  State<_AddTransactionFab> createState() => _AddTransactionFabState();
}

class _AddTransactionFabState extends State<_AddTransactionFab> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final button = widget.extended
        ? FloatingActionButton.extended(
            onPressed: () => _openAddTransaction(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addTransaction),
          )
        : FloatingActionButton(
            tooltip: l10n.addTransaction,
            onPressed: () => _openAddTransaction(context),
            child: const Icon(Icons.add),
          );

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: Semantics(
        button: true,
        label: l10n.addTransaction,
        child: AnimatedScale(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          scale: _pressed ? 0.96 : 1,
          child: button,
        ),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    final transactionsCubit = context.read<TransactionsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => BlocProvider.value(
        value: transactionsCubit,
        child: const AddTransactionSheet(),
      ),
    );
  }
}

class _AdaptiveNavigationRail extends StatelessWidget {
  const _AdaptiveNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.extended,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      minWidth: 76,
      minExtendedWidth: 196,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: Text(l10n.dashboardTab),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          selectedIcon: const Icon(Icons.receipt_long),
          label: Text(l10n.historyTab),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.pie_chart_outline),
          selectedIcon: const Icon(Icons.pie_chart),
          label: Text(l10n.reportsTab),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.savings_outlined),
          selectedIcon: const Icon(Icons.savings),
          label: Text(l10n.budgetsTab),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(l10n.settingsTab),
        ),
      ],
    );
  }
}

List<NavigationDestination> _navigationDestinations(AppLocalizations l10n) {
  return [
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
  ];
}
