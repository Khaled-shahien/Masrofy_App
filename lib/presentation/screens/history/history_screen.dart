import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/entities/financial_transaction.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/transactions/transactions_cubit.dart';
import '../../cubits/transactions/transactions_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/transactions/transaction_formatters.dart';
import '../../widgets/transactions/transaction_list_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
            icon: Icons.receipt_long_outlined,
            title: l10n.historyEmptyTitle,
            body: '${l10n.historyEmptyBody}\n${l10n.historyStartHint}',
          );
        }

        final categoriesById = {
          for (final category in state.categories) category.id: category,
        };
        final groups = _groupTransactionsByDay(
          state.transactions,
          localeName: l10n.localeName,
        );

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
                    child: Text(
                      l10n.historyTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                for (final group in groups) ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      padding.left,
                      AppSpacing.sm,
                      padding.right,
                      AppSpacing.xs,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        group.dayLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: padding.left),
                    sliver: SliverList.separated(
                      itemCount: group.transactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final transaction = group.transactions[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: TransactionListTile(
                              transaction: transaction,
                              category: categoriesById[transaction.categoryId],
                              onDelete: () => context
                                  .read<TransactionsCubit>()
                                  .delete(transaction.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
              ],
            );
          },
        );
      },
    );
  }
}

List<_TransactionDayGroup> _groupTransactionsByDay(
  List<FinancialTransaction> transactions, {
  required String localeName,
}) {
  final groups = <_TransactionDayGroup>[];

  for (final transaction in transactions) {
    final dayLabel = formatDay(transaction.date, localeName: localeName);
    if (groups.isNotEmpty && groups.last.dayLabel == dayLabel) {
      groups.last.transactions.add(transaction);
    } else {
      groups.add(
        _TransactionDayGroup(
          dayLabel: dayLabel,
          transactions: [transaction],
        ),
      );
    }
  }

  return groups;
}

class _TransactionDayGroup {
  _TransactionDayGroup({
    required this.dayLabel,
    required this.transactions,
  });

  final String dayLabel;
  final List<FinancialTransaction> transactions;
}
