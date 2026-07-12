import '../../domain/entities/financial_transaction.dart';
import '../widgets/transactions/transaction_formatters.dart';

class TransactionDayGroup {
  const TransactionDayGroup({
    required this.dayLabel,
    required this.transactions,
  });

  final String dayLabel;
  final List<FinancialTransaction> transactions;
}

List<TransactionDayGroup> groupTransactionsByDay(
  List<FinancialTransaction> transactions, {
  required String localeName,
}) {
  final groups = <TransactionDayGroup>[];

  for (final transaction in transactions) {
    final dayLabel = formatDay(transaction.date, localeName: localeName);
    if (groups.isNotEmpty && groups.last.dayLabel == dayLabel) {
      groups.last.transactions.add(transaction);
    } else {
      groups.add(
        TransactionDayGroup(
          dayLabel: dayLabel,
          transactions: [transaction],
        ),
      );
    }
  }

  return [
    for (final group in groups)
      TransactionDayGroup(
        dayLabel: group.dayLabel,
        transactions: List<FinancialTransaction>.unmodifiable(
          group.transactions,
        ),
      ),
  ];
}
