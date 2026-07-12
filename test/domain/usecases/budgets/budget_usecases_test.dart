import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/budgets/budget_local_data_source.dart';
import 'package:masrofy/data/datasources/categories/category_local_data_source.dart';
import 'package:masrofy/data/repositories/budget_repository_impl.dart';
import 'package:masrofy/data/repositories/category_repository_impl.dart';
import 'package:masrofy/domain/entities/budget.dart';
import 'package:masrofy/domain/entities/budget_period.dart';
import 'package:masrofy/domain/entities/budget_progress.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/budgets/budget_usecase_exception.dart';
import 'package:masrofy/domain/usecases/budgets/calculate_budget_progress.dart';
import 'package:masrofy/domain/usecases/budgets/delete_budget.dart';
import 'package:masrofy/domain/usecases/budgets/save_budget.dart';

void main() {
  late InMemoryBudgetLocalDataSource budgetDataSource;
  late InMemoryCategoryLocalDataSource categoryDataSource;
  late BudgetRepositoryImpl budgetRepository;
  late CategoryRepositoryImpl categoryRepository;

  setUp(() async {
    budgetDataSource = InMemoryBudgetLocalDataSource();
    categoryDataSource = InMemoryCategoryLocalDataSource();
    budgetRepository = BudgetRepositoryImpl(localDataSource: budgetDataSource);
    categoryRepository = CategoryRepositoryImpl(
      localDataSource: categoryDataSource,
    );
    await categoryRepository.saveCategories(const [
      Category(
        id: 'food',
        type: TransactionType.expense,
        name: 'Food',
        localizationKey: null,
        iconKey: 'restaurant',
        colorValue: 0xFF2A9D8F,
        sortOrder: 0,
      ),
      Category(
        id: 'salary',
        type: TransactionType.income,
        name: 'Salary',
        localizationKey: null,
        iconKey: 'payments',
        colorValue: 0xFF2A9D8F,
        sortOrder: 1,
      ),
    ]);
  });

  tearDown(() async {
    await budgetDataSource.close();
    await categoryDataSource.close();
  });

  test('SaveBudget creates and updates validated monthly budgets', () async {
    final usecase = SaveBudget(
      budgetRepository: budgetRepository,
      categoryRepository: categoryRepository,
      generateId: () => 'budget-1',
      now: () => DateTime(2026, 7, 1, 10),
    );

    await usecase(
      SaveBudgetInput(
        categoryId: 'food',
        amount: 1000,
        period: const BudgetPeriod(year: 2026, month: 7),
        note: '  groceries  ',
      ),
    );

    final created = (await budgetRepository.getBudgets()).single;
    expect(created.id, 'budget-1');
    expect(created.note, 'groceries');

    await usecase(
      SaveBudgetInput(
        id: created.id,
        categoryId: 'food',
        amount: 1200,
        period: created.period,
      ),
    );

    final updated = (await budgetRepository.getBudgets()).single;
    expect(updated.amount, 1200);
    expect(updated.createdAt, created.createdAt);
  });

  test('SaveBudget rejects duplicate and income-category budgets', () async {
    final usecase = SaveBudget(
      budgetRepository: budgetRepository,
      categoryRepository: categoryRepository,
      generateId: () => 'budget-1',
    );
    const period = BudgetPeriod(year: 2026, month: 7);

    await usecase(
      const SaveBudgetInput(
        categoryId: 'food',
        amount: 1000,
        period: period,
      ),
    );

    expect(
      () => usecase(
        const SaveBudgetInput(
          categoryId: 'food',
          amount: 900,
          period: period,
        ),
      ),
      throwsA(isA<DuplicateBudgetException>()),
    );
    expect(
      () => usecase(
        const SaveBudgetInput(
          categoryId: 'salary',
          amount: 900,
          period: period,
        ),
      ),
      throwsA(isA<BudgetCategoryException>()),
    );
  });

  test('DeleteBudget removes the stored budget', () async {
    await budgetRepository.saveBudget(
      _budget(id: 'budget-1', amount: 1000),
    );

    await DeleteBudget(budgetRepository)('budget-1');

    expect(await budgetRepository.getBudgets(), isEmpty);
  });

  test(
    'CalculateBudgetProgress uses expense transactions in the same month',
    () {
      final progress = const CalculateBudgetProgress()(
        budgets: [_budget(id: 'budget-1', amount: 1000)],
        transactions: [
          _transaction(
            id: 'expense-1',
            amount: 600,
            date: DateTime(2026, 7, 10),
            type: TransactionType.expense,
          ),
          _transaction(
            id: 'expense-2',
            amount: 500,
            date: DateTime(2026, 8),
            type: TransactionType.expense,
          ),
          _transaction(
            id: 'income-1',
            amount: 500,
            date: DateTime(2026, 7, 11),
            type: TransactionType.income,
          ),
        ],
      ).single;

      expect(progress.spentAmount, 600);
      expect(progress.remainingAmount, 400);
      expect(progress.status, BudgetStatus.safe);
    },
  );

  test('CalculateBudgetProgress detects approaching and exceeded budgets', () {
    final approaching = const CalculateBudgetProgress()(
      budgets: [_budget(id: 'budget-1', amount: 1000)],
      transactions: [
        _transaction(
          id: 'expense-1',
          amount: 850,
          date: DateTime(2026, 7, 10),
          type: TransactionType.expense,
        ),
      ],
    ).single;

    final exceeded = const CalculateBudgetProgress()(
      budgets: [_budget(id: 'budget-1', amount: 1000)],
      transactions: [
        _transaction(
          id: 'expense-1',
          amount: 1200,
          date: DateTime(2026, 7, 10),
          type: TransactionType.expense,
        ),
      ],
    ).single;

    expect(approaching.status, BudgetStatus.approaching);
    expect(exceeded.status, BudgetStatus.exceeded);
  });
}

Budget _budget({
  required String id,
  required double amount,
}) {
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
  required DateTime date,
  required TransactionType type,
}) {
  return FinancialTransaction(
    id: id,
    type: type,
    amount: amount,
    categoryId: 'food',
    date: date,
    createdAt: date,
    updatedAt: date,
  );
}
