import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/budgets/budget_local_data_source.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/datasources/transactions/transaction_local_data_source.dart';
import 'package:masrofy/data/models/budget_model.dart';
import 'package:masrofy/data/models/category_model.dart';
import 'package:masrofy/data/models/financial_transaction_model.dart';
import 'package:masrofy/data/repositories/budget_repository_impl.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/data/repositories/transaction_repository_impl.dart';
import 'package:masrofy/domain/entities/budget.dart';
import 'package:masrofy/domain/entities/budget_period.dart';
import 'package:masrofy/domain/entities/budget_progress.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/budgets/calculate_budget_progress.dart';
import 'package:masrofy/domain/usecases/budgets/delete_budget.dart';
import 'package:masrofy/domain/usecases/budgets/save_budget.dart';
import 'package:masrofy/domain/usecases/budgets/watch_budgets.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';
import 'package:masrofy/domain/usecases/transactions/watch_transactions.dart';
import 'package:masrofy/presentation/cubits/budgets/budgets_cubit.dart';
import 'package:masrofy/presentation/cubits/budgets/budgets_state.dart';

void main() {
  late InMemoryBudgetLocalDataSource budgetDataSource;
  late InMemoryCategoryLocalDataSource categoryDataSource;
  late InMemoryTransactionLocalDataSource transactionDataSource;
  late BudgetRepositoryImpl budgetRepository;
  late CategoryRepositoryImpl categoryRepository;
  late TransactionRepositoryImpl transactionRepository;

  BudgetsCubit buildCubit() {
    return BudgetsCubit(
      watchBudgets: WatchBudgets(budgetRepository),
      watchTransactions: WatchTransactions(transactionRepository),
      watchCategories: WatchCategories(categoryRepository),
      saveBudget: SaveBudget(
        budgetRepository: budgetRepository,
        categoryRepository: categoryRepository,
        generateId: () => 'budget-new',
        now: () => DateTime(2026, 7, 1, 12),
      ),
      deleteBudget: DeleteBudget(budgetRepository),
      calculateBudgetProgress: const CalculateBudgetProgress(),
      now: () => DateTime(2026, 7, 11),
    );
  }

  setUp(() async {
    budgetDataSource = InMemoryBudgetLocalDataSource([
      BudgetModel.fromDomain(_budget(id: 'budget-1', amount: 1000)),
    ]);
    categoryDataSource = InMemoryCategoryLocalDataSource([
      CategoryModel.fromDomain(_category()),
    ]);
    transactionDataSource = InMemoryTransactionLocalDataSource([
      FinancialTransactionModel.fromDomain(
        _transaction(id: 'tx-1', amount: 900),
      ),
    ]);
    budgetRepository = BudgetRepositoryImpl(localDataSource: budgetDataSource);
    categoryRepository = CategoryRepositoryImpl(
      localDataSource: categoryDataSource,
    );
    transactionRepository = TransactionRepositoryImpl(
      localDataSource: transactionDataSource,
    );
  });

  tearDown(() async {
    await budgetDataSource.close();
    await categoryDataSource.close();
    await transactionDataSource.close();
  });

  test('loads budget progress from budgets and expense transactions', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    final loaded = cubit.stream.firstWhere(
      (state) => state.status == BudgetsStatus.loaded,
    );
    cubit.load();
    final state = await loaded;

    expect(state.selectedPeriod, const BudgetPeriod(year: 2026, month: 7));
    expect(state.progress.single.spentAmount, 900);
    expect(state.progress.single.status, BudgetStatus.approaching);
  });

  test('saves budgets and maps duplicate validation errors', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    final loaded = cubit.stream.firstWhere(
      (state) => state.status == BudgetsStatus.loaded,
    );
    cubit.load();
    await loaded;

    final saved = await cubit.save(categoryId: 'food', amount: 500);

    expect(saved, isFalse);
    expect(cubit.state.failure, BudgetsFailure.duplicate);
  });

  test('month navigation reconnects budgets for the selected period', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    final loaded = cubit.stream.firstWhere(
      (state) => state.status == BudgetsStatus.loaded,
    );
    cubit.load();
    await loaded;

    final empty = cubit.stream.firstWhere(
      (state) => state.status == BudgetsStatus.empty,
    );
    cubit.nextMonth();
    final state = await empty;

    expect(state.selectedPeriod, const BudgetPeriod(year: 2026, month: 8));
    expect(state.progress, isEmpty);
  });
}

Budget _budget({required String id, required double amount}) {
  return Budget(
    id: id,
    categoryId: 'food',
    amount: amount,
    period: const BudgetPeriod(year: 2026, month: 7),
    createdAt: DateTime(2026, 7),
    updatedAt: DateTime(2026, 7),
  );
}

FinancialTransaction _transaction({
  required String id,
  required double amount,
}) {
  return FinancialTransaction(
    id: id,
    type: TransactionType.expense,
    amount: amount,
    categoryId: 'food',
    date: DateTime(2026, 7, 10),
    createdAt: DateTime(2026, 7, 10),
    updatedAt: DateTime(2026, 7, 10),
  );
}

Category _category() {
  return const Category(
    id: 'food',
    type: TransactionType.expense,
    name: 'Food',
    localizationKey: null,
    iconKey: 'restaurant',
    colorValue: 0xFF2A9D8F,
    sortOrder: 0,
  );
}
