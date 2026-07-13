import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/datasources/transactions/transaction_local_data_source.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/models/financial_transaction_model.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/data/repositories/transaction_repository_impl.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';
import 'package:masrofy/domain/usecases/transactions/delete_transaction.dart';
import 'package:masrofy/domain/usecases/transactions/save_transaction.dart';
import 'package:masrofy/domain/usecases/transactions/watch_transactions.dart';
import 'package:masrofy/presentation/cubits/transactions/transactions_cubit.dart';
import 'package:masrofy/presentation/cubits/transactions/transactions_state.dart';

void main() {
  late InMemoryCategoryLocalDataSource categoryDataSource;
  late InMemoryTransactionLocalDataSource transactionDataSource;
  late TransactionsCubit cubit;

  setUp(() {
    categoryDataSource = InMemoryCategoryLocalDataSource([
      CategoryModel.fromDomain(_category('food', TransactionType.expense)),
      CategoryModel.fromDomain(_category('salary', TransactionType.income)),
    ]);
    transactionDataSource = InMemoryTransactionLocalDataSource([
      FinancialTransactionModel.fromDomain(
        _transaction(
          id: 'food-1',
          type: TransactionType.expense,
          categoryId: 'food',
          note: 'Groceries',
          wallet: WalletType.cash,
        ),
      ),
      FinancialTransactionModel.fromDomain(
        _transaction(
          id: 'salary-1',
          type: TransactionType.income,
          categoryId: 'salary',
          note: 'July salary',
          wallet: WalletType.instaPay,
        ),
      ),
    ]);
    final categoryRepository = CategoryRepositoryImpl(
      localDataSource: categoryDataSource,
    );
    final transactionRepository = TransactionRepositoryImpl(
      localDataSource: transactionDataSource,
    );
    cubit = TransactionsCubit(
      watchTransactions: WatchTransactions(transactionRepository),
      watchCategories: WatchCategories(categoryRepository),
      saveTransaction: SaveTransaction(
        repository: transactionRepository,
        categoryRepository: categoryRepository,
      ),
      deleteTransaction: DeleteTransaction(transactionRepository),
    );
  });

  tearDown(() async {
    await cubit.close();
    await categoryDataSource.close();
    await transactionDataSource.close();
  });

  test('loads filtered transactions and applies type filters', () async {
    final ready = cubit.stream.firstWhere(
      (state) =>
          state.status == TransactionsStatus.ready &&
          state.transactions.length == 2,
    );
    cubit.load();
    await ready;

    cubit.setTypeFilter(TransactionType.expense);

    expect(cubit.state.filteredTransactions, hasLength(1));
    expect(cubit.state.filteredTransactions.single.id, 'food-1');
  });

  test('debounces local search', () async {
    final ready = cubit.stream.firstWhere(
      (state) =>
          state.status == TransactionsStatus.ready &&
          state.transactions.length == 2,
    );
    cubit.load();
    await ready;

    cubit.updateSearchQuery('salary');
    expect(cubit.state.filter.query, isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(cubit.state.filter.query, 'salary');
    expect(cubit.state.filteredTransactions.single.id, 'salary-1');
  });
}

Category _category(String id, TransactionType type) {
  return Category(
    id: id,
    type: type,
    name: id,
    localizationKey: null,
    iconKey: 'category',
    colorValue: 0xFF2A9D8F,
    sortOrder: 0,
  );
}

FinancialTransaction _transaction({
  required String id,
  required TransactionType type,
  required String categoryId,
  required String note,
  required WalletType wallet,
}) {
  return FinancialTransaction(
    id: id,
    type: type,
    amount: type == TransactionType.expense ? 120 : 1000,
    categoryId: categoryId,
    wallet: wallet,
    note: note,
    date: DateTime(2026, 7, 10),
    createdAt: DateTime(2026, 7, 10),
    updatedAt: DateTime(2026, 7, 10),
  );
}
