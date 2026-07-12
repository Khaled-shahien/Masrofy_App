import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../di/service_locator.dart';
import '../../../domain/entities/dashboard_summary.dart';
import '../../../domain/usecases/dashboard/build_dashboard_summary.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/transactions/transactions_cubit.dart';
import '../../cubits/transactions/transactions_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/privacy/financial_privacy.dart';
import '../../widgets/transactions/add_transaction_sheet.dart';
import '../../widgets/transactions/transaction_formatters.dart';
import '../../widgets/transactions/transaction_list_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final obscureAmounts = financialAmountsObscured(context);

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state.status == TransactionsStatus.loading) {
          return const LoadingSkeleton();
        }
        if (!state.hasTransactions) {
          return EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.dashboardEmptyTitle,
            body: '${l10n.dashboardEmptyBody}\n${l10n.dashboardStartHint}',
            action: FilledButton(
              onPressed: () => _openAddTransaction(context),
              child: Text(l10n.addTransactionTitle),
            ),
          );
        }

        final summary = serviceLocator<BuildDashboardSummary>()(
          state.transactions,
        );
        final categoriesById = {
          for (final category in state.categories) category.id: category,
        };
        final recent = state.transactions.take(5).toList(growable: false);

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
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _DashboardHeroCard(
                      totals: summary.month,
                      dateLabel: formatDay(
                        DateTime.now(),
                        localeName: l10n.localeName,
                      ),
                      obscureAmounts: obscureAmounts,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: padding.left),
                  sliver: SliverToBoxAdapter(
                    child: _SummaryGrid(
                      today: summary.today,
                      week: summary.week,
                      month: summary.month,
                      obscureAmounts: obscureAmounts,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.lg,
                    padding.right,
                    AppSpacing.xs,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      l10n.dashboardRecentTransactionsTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    0,
                    padding.right,
                    padding.bottom,
                  ),
                  sliver: SliverList.separated(
                    itemCount: recent.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final transaction = recent[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: TransactionListTile(
                            transaction: transaction,
                            category: categoriesById[transaction.categoryId],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.today,
    required this.week,
    required this.month,
    required this.obscureAmounts,
  });

  final DashboardPeriodTotals today;
  final DashboardPeriodTotals week;
  final DashboardPeriodTotals month;
  final bool obscureAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _SummaryCard(
            title: l10n.summaryToday,
            totals: today,
            obscureAmounts: obscureAmounts,
          ),
          _SummaryCard(
            title: l10n.summaryWeek,
            totals: week,
            obscureAmounts: obscureAmounts,
          ),
          _SummaryCard(
            title: l10n.summaryMonth,
            totals: month,
            obscureAmounts: obscureAmounts,
          ),
        ];
        if (constraints.maxWidth >= AppBreakpoints.tablet) {
          return Row(
            children: [
              for (final card in cards) ...[
                Expanded(child: card),
                if (card != cards.last) const SizedBox(width: AppSpacing.xs),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (final card in cards) ...[
              card,
              if (card != cards.last) const SizedBox(height: AppSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.totals,
    required this.obscureAmounts,
  });

  final String title;
  final DashboardPeriodTotals totals;
  final bool obscureAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: textTheme.titleMedium)),
                Icon(
                  Icons.trending_flat,
                  size: AppIconSizes.sm,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _AmountMetric(
                    label: l10n.summaryExpense,
                    value: totals.expense,
                    color: colors.expense,
                    obscure: obscureAmounts,
                  ),
                ),
                Expanded(
                  child: _AmountMetric(
                    label: l10n.summaryIncome,
                    value: totals.income,
                    color: colors.income,
                    obscure: obscureAmounts,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: AppDurations.standard,
              switchInCurve: AppCurves.standard,
              switchOutCurve: AppCurves.standard,
              child: Text(
                key: ValueKey(totals.net),
                l10n.summaryNet(
                  formatMoney(
                    totals.net,
                    localeName: l10n.localeName,
                    currencySymbol: l10n.currencySymbol,
                    obscure: obscureAmounts,
                  ),
                ),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.totals,
    required this.dateLabel,
    required this.obscureAmounts,
  });

  final DashboardPeriodTotals totals;
  final String dateLabel;
  final bool obscureAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final netAmount = formatMoney(
      totals.net,
      localeName: l10n.localeName,
      currencySymbol: l10n.currencySymbol,
      obscure: obscureAmounts,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppRadii.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardSummaryTitle,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        dateLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.42),
                    borderRadius: AppRadii.pill,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: AppDurations.standard,
              switchInCurve: AppCurves.standard,
              switchOutCurve: AppCurves.standard,
              child: Text(
                netAmount,
                key: ValueKey(netAmount),
                textDirection: TextDirection.ltr,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final metrics = [
                  _HeroMetric(
                    icon: Icons.south_west,
                    label: l10n.summaryExpense,
                    amount: totals.expense,
                    color: colors.expense,
                    obscureAmounts: obscureAmounts,
                  ),
                  _HeroMetric(
                    icon: Icons.north_east,
                    label: l10n.summaryIncome,
                    amount: totals.income,
                    color: colors.income,
                    obscureAmounts: obscureAmounts,
                  ),
                ];
                if (constraints.maxWidth < 430) {
                  return Column(
                    children: [
                      for (final metric in metrics) ...[
                        metric,
                        if (metric != metrics.last)
                          const SizedBox(height: AppSpacing.xs),
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    for (final metric in metrics) ...[
                      Expanded(child: metric),
                      if (metric != metrics.last)
                        const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.obscureAmounts,
  });

  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final bool obscureAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.58),
        borderRadius: AppRadii.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: AppIconSizes.sm, color: color),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    formatMoney(
                      amount,
                      localeName: l10n.localeName,
                      currencySymbol: l10n.currencySymbol,
                      obscure: obscureAmounts,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountMetric extends StatelessWidget {
  const _AmountMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.obscure,
  });

  final String label;
  final double value;
  final Color color;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          formatMoney(
            value,
            localeName: l10n.localeName,
            currencySymbol: l10n.currencySymbol,
            obscure: obscure,
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

Future<void> _openAddTransaction(BuildContext context) {
  final cubit = context.read<TransactionsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: const AddTransactionSheet(),
    ),
  );
}
