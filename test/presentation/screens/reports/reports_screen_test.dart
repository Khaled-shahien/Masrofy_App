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
import 'package:masrofy/domain/usecases/reports/build_report.dart';
import 'package:masrofy/domain/usecases/transactions/watch_transactions.dart';
import 'package:masrofy/l10n/generated/app_localizations.dart';
import 'package:masrofy/presentation/cubits/reports/reports_cubit.dart';
import 'package:masrofy/presentation/cubits/reports/reports_state.dart';
import 'package:masrofy/presentation/screens/reports/reports_screen.dart';

void main() {
  testWidgets('renders report metrics, charts, and filters', (tester) async {
    final harness = _ReportHarness(hasTransactions: true);
    addTearDown(harness.close);
    final loaded = harness.cubit.stream.firstWhere(
      (state) => state.status == ReportsStatus.loaded,
    );
    harness.cubit.load();
    await loaded;

    await _pumpScreen(tester, harness.cubit);

    expect(find.text('Spending report'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Expense distribution'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Expense distribution'), findsOneWidget);
    expect(find.text('Trend over time'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Food'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Food'), findsWidgets);
  });

  testWidgets('renders empty report state for selected filters', (
    tester,
  ) async {
    final harness = _ReportHarness(hasTransactions: false);
    addTearDown(harness.close);
    final empty = harness.cubit.stream.firstWhere(
      (state) => state.status == ReportsStatus.empty,
    );
    harness.cubit.load();
    await empty;

    await _pumpScreen(tester, harness.cubit);

    expect(find.text('No report data'), findsOneWidget);
    expect(find.textContaining('Record one expense'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  ReportsCubit cubit,
) async {
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const Scaffold(body: ReportsScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ReportHarness {
  _ReportHarness({required bool hasTransactions}) {
    categoryDataSource = InMemoryCategoryLocalDataSource([
      CategoryModel.fromDomain(_category('food', TransactionType.expense)),
      CategoryModel.fromDomain(_category('salary', TransactionType.income)),
    ]);
    transactionDataSource = InMemoryTransactionLocalDataSource([
      if (hasTransactions) ...[
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
      ],
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
  }

  late final InMemoryCategoryLocalDataSource categoryDataSource;
  late final InMemoryTransactionLocalDataSource transactionDataSource;
  late final ReportsCubit cubit;

  Future<void> close() async {
    await cubit.close();
    await categoryDataSource.close();
    await transactionDataSource.close();
  }
}

Category _category(String id, TransactionType type) {
  return Category(
    id: id,
    type: type,
    name: id == 'food' ? 'Food' : 'Salary',
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
