import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/transactions/transactions_cubit.dart';
import '../../cubits/transactions/transactions_state.dart';
import '../../widgets/categories/category_localization.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/transactions/transaction_formatters.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state.status == TransactionsStatus.loading) {
          return const LoadingSkeleton();
        }
        final expenseTransactions = state.transactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .toList(growable: false);
        if (expenseTransactions.isEmpty) {
          return EmptyState(
            icon: Icons.query_stats,
            title: l10n.reportsEmptyTitle,
            body: '${l10n.reportsEmptyBody}\n${l10n.reportsStartHint}',
          );
        }

        final totalsByCategory = <String, double>{};
        for (final transaction in expenseTransactions) {
          totalsByCategory.update(
            transaction.categoryId,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
        final totalExpense = totalsByCategory.values.fold<double>(
          0,
          (sum, value) => sum + value,
        );
        final categoriesById = {
          for (final category in state.categories) category.id: category,
        };
        final rows = totalsByCategory.entries.toList()
          ..sort((left, right) => right.value.compareTo(left.value));

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
                    child: _ReportHero(totalExpense: totalExpense),
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
                    itemCount: rows.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return _CategoryReportRow(
                        categoryName: categoriesById[row.key] == null
                            ? l10n.unknownCategory
                            : localizedCategoryName(
                                l10n,
                                categoriesById[row.key]!,
                              ),
                        amount: row.value,
                        ratio: totalExpense == 0 ? 0 : row.value / totalExpense,
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

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.totalExpense});

  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportsTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.reportsTotalExpense(
                formatMoney(
                  totalExpense,
                  localeName: l10n.localeName,
                  currencySymbol: l10n.currencySymbol,
                ),
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryReportRow extends StatelessWidget {
  const _CategoryReportRow({
    required this.categoryName,
    required this.amount,
    required this.ratio,
  });

  final String categoryName;
  final double amount;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  formatMoney(
                    amount,
                    localeName: l10n.localeName,
                    currencySymbol: l10n.currencySymbol,
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: AppRadii.pill,
              child: LinearProgressIndicator(
                minHeight: 8,
                value: ratio.clamp(0, 1),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(l10n.reportsExpenseRatio((ratio * 100).round())),
          ],
        ),
      ),
    );
  }
}
