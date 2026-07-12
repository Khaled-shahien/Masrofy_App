import '../../entities/budget.dart';
import '../../entities/budget_progress.dart';
import '../../entities/financial_transaction.dart';
import '../../entities/transaction_type.dart';
import 'budget_rules.dart';

/// Calculates budget consumption from real expense transactions.
class CalculateBudgetProgress {
  const CalculateBudgetProgress();

  List<BudgetProgress> call({
    required Iterable<Budget> budgets,
    required Iterable<FinancialTransaction> transactions,
  }) {
    final expenseTransactions = transactions.where(
      (transaction) => transaction.type == TransactionType.expense,
    );

    return budgets
        .map((budget) {
          final spent = expenseTransactions
              .where(
                (transaction) =>
                    transaction.categoryId == budget.categoryId &&
                    budget.period.contains(transaction.date),
              )
              .fold<double>(
                0,
                (total, transaction) => total + transaction.amount,
              );
          final ratio = budget.amount == 0 ? 0.0 : spent / budget.amount;
          final remaining = budget.amount - spent;
          return BudgetProgress(
            budget: budget,
            spentAmount: spent,
            remainingAmount: remaining,
            progressRatio: ratio,
            status: _statusFor(ratio),
          );
        })
        .toList(growable: false);
  }

  BudgetStatus _statusFor(double ratio) {
    if (ratio >= 1) {
      return BudgetStatus.exceeded;
    }
    if (ratio >= BudgetRules.approachingLimitRatio) {
      return BudgetStatus.approaching;
    }
    return BudgetStatus.safe;
  }
}
