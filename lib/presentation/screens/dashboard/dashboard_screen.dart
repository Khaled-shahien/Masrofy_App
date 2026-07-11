import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/transactions/transactions_cubit.dart';
import '../../cubits/transactions/transactions_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/transactions/transaction_formatters.dart';
import '../../widgets/transactions/transaction_list_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          );
        }

        final now = DateTime.now();
        final today = _sumFor(
          state.transactions,
          (transaction) => isSameDay(transaction.date, now),
        );
        final week = _sumFor(
          state.transactions,
          (transaction) => isInCurrentWeek(transaction.date, now),
        );
        final month = _sumFor(
          state.transactions,
          (transaction) => isSameMonth(transaction.date, now),
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
                    AppSpacing.xs,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      l10n.dashboardSummaryTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: padding.left),
                  sliver: SliverToBoxAdapter(
                    child: _SummaryGrid(
                      today: today,
                      week: week,
                      month: month,
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
  });

  final _Totals today;
  final _Totals week;
  final _Totals month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _SummaryCard(title: l10n.summaryToday, totals: today),
          _SummaryCard(title: l10n.summaryWeek, totals: week),
          _SummaryCard(title: l10n.summaryMonth, totals: month),
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
  const _SummaryCard({required this.title, required this.totals});

  final String title;
  final _Totals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _AmountMetric(
                    label: l10n.summaryExpense,
                    value: totals.expense,
                    color: colors.expense,
                  ),
                ),
                Expanded(
                  child: _AmountMetric(
                    label: l10n.summaryIncome,
                    value: totals.income,
                    color: colors.income,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                key: ValueKey(totals.net),
                l10n.summaryNet(
                  formatMoney(
                    totals.net,
                    localeName: l10n.localeName,
                    currencySymbol: l10n.currencySymbol,
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

class _AmountMetric extends StatelessWidget {
  const _AmountMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

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
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Totals {
  const _Totals({required this.income, required this.expense});

  final double income;
  final double expense;

  double get net => income - expense;
}

_Totals _sumFor(
  Iterable<FinancialTransaction> transactions,
  bool Function(FinancialTransaction transaction) test,
) {
  var income = 0.0;
  var expense = 0.0;
  for (final transaction in transactions.where(test)) {
    switch (transaction.type) {
      case TransactionType.income:
        income += transaction.amount;
      case TransactionType.expense:
        expense += transaction.amount;
    }
  }
  return _Totals(income: income, expense: expense);
}
