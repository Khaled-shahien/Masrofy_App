import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/datasources/transactions/transaction_local_data_source.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/models/financial_transaction_model.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/data/repositories/transaction_repository_impl.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/report_filter.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/entities/wallet_type.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';
import 'package:masrofy/domain/usecases/reports/build_report.dart';
import 'package:masrofy/domain/usecases/transactions/watch_transactions.dart';
import 'package:masrofy/presentation/cubits/reports/reports_cubit.dart';
import 'package:masrofy/presentation/cubits/reports/reports_state.dart';

void main() {
  late InMemoryCategoryLocalDataSource categoryDataSource;
  late InMemoryTransactionLocalDataSource transactionDataSource;
  late ReportsCubit cubit;

  setUp(() {
    categoryDataSource = InMemoryCategoryLocalDataSource([
      CategoryModel.fromDomain(_category('food', TransactionType.expense)),
      CategoryModel.fromDomain(_category('salary', TransactionType.income)),
    ]);
    transactionDataSource = InMemoryTransactionLocalDataSource([
      FinancialTransactionModel.fromDomain(
        _transaction(
          id: 'expense',
          type: TransactionType.expense,
          amount: 250,
          categoryId: 'food',
          wallet: WalletType.cash,
        ),
      ),
      FinancialTransactionModel.fromDomain(
        _transaction(
          id: 'income',
          type: TransactionType.income,
          amount: 900,
          categoryId: 'salary',
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
    cubit = ReportsCubit(
      watchTransactions: WatchTransactions(transactionRepository),
      watchCategories: WatchCategories(categoryRepository),
      buildReport: BuildReport(now: () => DateTime(2026, 7, 15)),
    );
  });

  tearDown(() async {
    await cubit.close();
    await categoryDataSource.close();
    await transactionDataSource.close();
  });

  test('loads a report from transaction and category streams', () async {
    final loaded = cubit.stream.firstWhere(
      (state) => state.status == ReportsStatus.loaded,
    );

    cubit.load();
    final state = await loaded;

    expect(state.report?.summary.totalExpense, 250);
    expect(state.report?.summary.totalIncome, 900);
    expect(state.categories, hasLength(2));
  });

  test('updates report when filters change', () async {
    final loaded = cubit.stream.firstWhere(
      (state) => state.status == ReportsStatus.loaded,
    );
    cubit.load();
    await loaded;

    cubit.setWallet(WalletType.cash);

    expect(cubit.state.filter.wallet, WalletType.cash);
    expect(cubit.state.report?.summary.totalExpense, 250);
    expect(cubit.state.report?.summary.totalIncome, 0);

    cubit.setTransactionType(TransactionType.income);
    expect(cubit.state.status, ReportsStatus.empty);
    expect(cubit.state.report?.summary.transactionCount, 0);

    cubit.clearFilters();
    expect(cubit.state.filter, const ReportFilter());
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
  required double amount,
  required String categoryId,
  required WalletType wallet,
}) {
  return FinancialTransaction(
    id: id,
    type: type,
    amount: amount,
    categoryId: categoryId,
    wallet: wallet,
    date: DateTime(2026, 7, 10),
    createdAt: DateTime(2026, 7, 10),
    updatedAt: DateTime(2026, 7, 10),
  );
}
