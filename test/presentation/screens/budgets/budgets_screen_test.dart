import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/theme/app_theme.dart';
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
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/budgets/calculate_budget_progress.dart';
import 'package:masrofy/domain/usecases/budgets/delete_budget.dart';
import 'package:masrofy/domain/usecases/budgets/save_budget.dart';
import 'package:masrofy/domain/usecases/budgets/watch_budgets.dart';
import 'package:masrofy/domain/usecases/categories/watch_categories.dart';
import 'package:masrofy/domain/usecases/transactions/watch_transactions.dart';
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/cubits/budgets/budgets_cubit.dart';
import 'package:masrofy/presentation/cubits/budgets/budgets_state.dart';
import 'package:masrofy/presentation/screens/budgets/budgets_screen.dart';

void main() {
  testWidgets('shows empty state and opens the budget editor', (tester) async {
    final harness = _BudgetHarness(seedBudget: false);
    addTearDown(harness.close);
    final loaded = harness.cubit.stream.firstWhere(
      (state) => state.status == BudgetsStatus.empty,
    );
    harness.cubit.load();
    await loaded;

    await _pumpScreen(tester, harness.cubit);

    expect(find.text('No budgets'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('add-budget-empty-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('budget-editor-sheet')), findsOneWidget);
    expect(find.text('Budget amount'), findsOneWidget);
  });

  testWidgets('renders exceeded budget progress and delete confirmation', (
    tester,
  ) async {
    final harness = _BudgetHarness(seedBudget: true, spentAmount: 1200);
    addTearDown(harness.close);
    final loaded = harness.cubit.stream.firstWhere(
      (state) => state.status == BudgetsStatus.loaded,
    );
    harness.cubit.load();
    await loaded;

    await _pumpScreen(tester, harness.cubit);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Exceeded'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('budget-delete-budget-1')));
    await tester.pumpAndSettle();

    expect(find.text('Delete budget'), findsOneWidget);
    expect(find.text('Delete the budget for Food?'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  BudgetsCubit cubit,
) async {
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const Scaffold(body: BudgetsScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _BudgetHarness {
  _BudgetHarness({
    required bool seedBudget,
    double spentAmount = 0,
  }) {
    budgetDataSource = InMemoryBudgetLocalDataSource([
      if (seedBudget)
        BudgetModel.fromDomain(
          Budget(
            id: 'budget-1',
            categoryId: 'food',
            amount: 1000,
            period: const BudgetPeriod(year: 2026, month: 7),
            createdAt: DateTime(2026, 7),
            updatedAt: DateTime(2026, 7),
          ),
        ),
    ]);
    categoryDataSource = InMemoryCategoryLocalDataSource([
      CategoryModel.fromDomain(_category()),
    ]);
    transactionDataSource = InMemoryTransactionLocalDataSource([
      if (spentAmount > 0)
        FinancialTransactionModel.fromDomain(
          FinancialTransaction(
            id: 'tx-1',
            type: TransactionType.expense,
            amount: spentAmount,
            categoryId: 'food',
            date: DateTime(2026, 7, 10),
            createdAt: DateTime(2026, 7, 10),
            updatedAt: DateTime(2026, 7, 10),
          ),
        ),
    ]);
    final budgetRepository = BudgetRepositoryImpl(
      localDataSource: budgetDataSource,
    );
    final categoryRepository = CategoryRepositoryImpl(
      localDataSource: categoryDataSource,
    );
    final transactionRepository = TransactionRepositoryImpl(
      localDataSource: transactionDataSource,
    );
    cubit = BudgetsCubit(
      watchBudgets: WatchBudgets(budgetRepository),
      watchTransactions: WatchTransactions(transactionRepository),
      watchCategories: WatchCategories(categoryRepository),
      saveBudget: SaveBudget(
        budgetRepository: budgetRepository,
        categoryRepository: categoryRepository,
        generateId: () => 'budget-new',
      ),
      deleteBudget: DeleteBudget(budgetRepository),
      calculateBudgetProgress: const CalculateBudgetProgress(),
      now: () => DateTime(2026, 7, 11),
    );
  }

  late final InMemoryBudgetLocalDataSource budgetDataSource;
  late final InMemoryCategoryLocalDataSource categoryDataSource;
  late final InMemoryTransactionLocalDataSource transactionDataSource;
  late final BudgetsCubit cubit;

  Future<void> close() async {
    await cubit.close();
    await budgetDataSource.close();
    await categoryDataSource.close();
    await transactionDataSource.close();
  }
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
