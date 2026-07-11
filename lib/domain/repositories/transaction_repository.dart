import '../entities/financial_transaction.dart';

/// Provides local persistence for daily income and expense entries.
abstract interface class TransactionRepository {
  Future<List<FinancialTransaction>> getTransactions();

  Stream<List<FinancialTransaction>> watchTransactions();

  Future<void> saveTransaction(FinancialTransaction transaction);

  Future<void> deleteTransaction(String id);
}
