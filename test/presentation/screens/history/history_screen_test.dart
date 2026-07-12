import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/theme/app_theme.dart';
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
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/cubits/transactions/transactions_cubit.dart';
import 'package:masrofy/presentation/cubits/transactions/transactions_state.dart';
import 'package:masrofy/presentation/screens/history/history_screen.dart';

void main() {
  testWidgets('filters history with debounced search', (tester) async {
    final harness = _HistoryHarness();
    addTearDown(harness.close);
    final ready = harness.cubit.stream.firstWhere(
      (state) =>
          state.status == TransactionsStatus.ready &&
          state.transactions.length == 2,
    );
    harness.cubit.load();
    await ready;

    await _pumpScreen(tester, harness.cubit);

    await tester.enterText(
      find.byKey(const ValueKey('transaction-search-field')),
      'salary',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('opens details and edit transaction sheet', (tester) async {
    final harness = _HistoryHarness();
    addTearDown(harness.close);
    final ready = harness.cubit.stream.firstWhere(
      (state) =>
          state.status == TransactionsStatus.ready &&
          state.transactions.length == 2,
    );
    harness.cubit.load();
    await ready;

    await _pumpScreen(tester, harness.cubit);

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction details'), findsOneWidget);

    await tester.tap(find.text('Edit transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Edit transaction'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('transaction_amount_field')),
      findsOneWidget,
    );
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  TransactionsCubit cubit,
) async {
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const Scaffold(body: HistoryScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _HistoryHarness {
  _HistoryHarness() {
    categoryDataSource = InMemoryCategoryLocalDataSource([
      CategoryModel.fromDomain(
        _category('food', 'Food', TransactionType.expense),
      ),
      CategoryModel.fromDomain(
        _category('salary', 'Salary', TransactionType.income),
      ),
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
        now: () => DateTime(2026, 7, 12),
      ),
      deleteTransaction: DeleteTransaction(transactionRepository),
    );
  }

  late final InMemoryCategoryLocalDataSource categoryDataSource;
  late final InMemoryTransactionLocalDataSource transactionDataSource;
  late final TransactionsCubit cubit;

  Future<void> close() async {
    await cubit.close();
    await categoryDataSource.close();
    await transactionDataSource.close();
  }
}

Category _category(String id, String name, TransactionType type) {
  return Category(
    id: id,
    type: type,
    name: name,
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
