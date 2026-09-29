import '../../domain/entities/financial_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transactions/transaction_local_data_source.dart';
import '../models/financial_transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl({
    required this._localDataSource,
  });

  final TransactionLocalDataSource _localDataSource;

  @override
  Future<List<FinancialTransaction>> getTransactions() async {
    final models = await _localDataSource.getTransactions();
    return _mapAndSort(models);
  }

  @override
  Future<void> saveTransaction(FinancialTransaction transaction) {
    return _localDataSource.saveTransaction(
      FinancialTransactionModel.fromDomain(transaction),
    );
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _localDataSource.deleteTransaction(id);
  }

  @override
  Stream<List<FinancialTransaction>> watchTransactions() {
    return _localDataSource.watchTransactions().map(_mapAndSort);
  }

  List<FinancialTransaction> _mapAndSort(
    Iterable<FinancialTransactionModel> models,
  ) {
    final transactions = models.map((model) => model.toDomain()).toList();
    transactions.sort((left, right) => right.date.compareTo(left.date));
    return List<FinancialTransaction>.unmodifiable(transactions);
  }
}
