import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/data/datasources/budgets/budget_local_data_source.dart';
import 'package:masrofy/data/repositories/budget_repository_impl.dart';
import 'package:masrofy/domain/entities/budget.dart';
import 'package:masrofy/domain/entities/budget_period.dart';

void main() {
  test('saves, filters, watches, and deletes budgets', () async {
    final dataSource = InMemoryBudgetLocalDataSource();
    addTearDown(dataSource.close);
    final repository = BudgetRepositoryImpl(localDataSource: dataSource);
    const period = BudgetPeriod(year: 2026, month: 7);
    const otherPeriod = BudgetPeriod(year: 2026, month: 8);

    final snapshots = <List<Budget>>[];
    final subscription = repository
        .watchBudgets(period: period)
        .listen(snapshots.add);
    addTearDown(subscription.cancel);

    final july = _budget(id: 'july', period: period);
    final august = _budget(id: 'august', period: otherPeriod);
    await repository.saveBudget(july);
    await repository.saveBudget(august);

    final budgets = await repository.getBudgets(period: period);
    expect(budgets.single.id, 'july');

    await repository.deleteBudget('july');
    expect(await repository.getBudgets(period: period), isEmpty);
    expect(snapshots, isNotEmpty);
  });

  test('excludes archived budgets unless explicitly requested', () async {
    final dataSource = InMemoryBudgetLocalDataSource();
    addTearDown(dataSource.close);
    final repository = BudgetRepositoryImpl(localDataSource: dataSource);
    const period = BudgetPeriod(year: 2026, month: 7);

    await repository.saveBudget(
      _budget(id: 'archived', period: period, isArchived: true),
    );

    expect(await repository.getBudgets(period: period), isEmpty);
    expect(
      await repository.getBudgets(period: period, includeArchived: true),
      hasLength(1),
    );
  });
}

Budget _budget({
  required String id,
  required BudgetPeriod period,
  bool isArchived = false,
}) {
  return Budget(
    id: id,
    categoryId: 'food',
    amount: 1000,
    period: period,
    isArchived: isArchived,
    createdAt: period.start,
    updatedAt: period.start,
  );
}
