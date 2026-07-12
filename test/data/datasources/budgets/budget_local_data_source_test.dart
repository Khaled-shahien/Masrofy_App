import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:masrofy/data/datasources/budgets/budget_local_data_source.dart';
import 'package:masrofy/data/models/budget_model.dart';

void main() {
  late Directory temporaryDirectory;
  late Box<String> box;
  late HiveBudgetLocalDataSource dataSource;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'masrofy_budgets_test_',
    );
    Hive.init(temporaryDirectory.path);
    box = await Hive.openBox<String>('budgets');
    dataSource = HiveBudgetLocalDataSource(box);
  });

  tearDown(() async {
    await box.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('stores budget records as JSON strings by stable ID', () async {
    final model = BudgetModel(
      id: 'budget-1',
      categoryId: 'food',
      amount: 1000,
      month: 7,
      year: 2026,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

    await dataSource.saveBudget(model);

    final stored = box.get(model.id);
    if (stored == null) {
      fail('Expected a persisted budget JSON string.');
    }
    final json = jsonDecode(stored) as Map<String, dynamic>;
    expect(json['categoryId'], 'food');
    expect(json['month'], 7);
    final budgets = await dataSource.getBudgets();
    expect(budgets, hasLength(1));
    expect(budgets.single.id, model.id);
    expect(budgets.single.categoryId, model.categoryId);
  });

  test('deletes budgets by stable ID', () async {
    final model = BudgetModel(
      id: 'budget-1',
      categoryId: 'food',
      amount: 1000,
      month: 7,
      year: 2026,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

    await dataSource.saveBudget(model);
    await dataSource.deleteBudget(model.id);

    expect(await dataSource.getBudgets(), isEmpty);
  });
}
