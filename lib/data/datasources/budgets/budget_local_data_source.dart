import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import '../../models/budget_model.dart';

abstract interface class BudgetLocalDataSource {
  Stream<List<BudgetModel>> watchBudgets();

  Future<List<BudgetModel>> getBudgets();

  Future<void> saveBudget(BudgetModel budget);

  Future<void> deleteBudget(String id);

  Future<void> replaceBudgets(Iterable<BudgetModel> budgets);
}

/// Persists budget JSON in the versioned local Hive budget box.
class HiveBudgetLocalDataSource implements BudgetLocalDataSource {
  const HiveBudgetLocalDataSource(this._box);

  final Box<String> _box;

  @override
  Future<List<BudgetModel>> getBudgets() async {
    return _box.values.map(_decode).toList(growable: false);
  }

  @override
  Future<void> saveBudget(BudgetModel budget) {
    return _box.put(budget.id, jsonEncode(budget.toJson()));
  }

  @override
  Future<void> deleteBudget(String id) {
    return _box.delete(id);
  }

  @override
  Future<void> replaceBudgets(Iterable<BudgetModel> budgets) async {
    await _box.clear();
    await _box.putAll(<String, String>{
      for (final budget in budgets) budget.id: jsonEncode(budget.toJson()),
    });
  }

  @override
  Stream<List<BudgetModel>> watchBudgets() => _watchSnapshots(
    changes: _box.watch(),
    load: getBudgets,
  );

  BudgetModel _decode(String value) {
    final decoded = jsonDecode(value);
    return switch (decoded) {
      Map<String, dynamic> json => BudgetModel.fromJson(json),
      _ => throw const FormatException('Stored budget must be a JSON map.'),
    };
  }
}

/// Provides deterministic budget persistence for tests and local previews.
class InMemoryBudgetLocalDataSource implements BudgetLocalDataSource {
  InMemoryBudgetLocalDataSource([Iterable<BudgetModel> seed = const []])
    : _records = {for (final budget in seed) budget.id: budget};

  final Map<String, BudgetModel> _records;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  @override
  Future<List<BudgetModel>> getBudgets() async {
    return List<BudgetModel>.unmodifiable(_records.values);
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    _records[budget.id] = budget;
    _changes.add(null);
  }

  @override
  Future<void> deleteBudget(String id) async {
    _records.remove(id);
    _changes.add(null);
  }

  @override
  Future<void> replaceBudgets(Iterable<BudgetModel> budgets) async {
    _records
      ..clear()
      ..addAll({for (final budget in budgets) budget.id: budget});
    _changes.add(null);
  }

  @override
  Stream<List<BudgetModel>> watchBudgets() => _watchSnapshots(
    changes: _changes.stream,
    load: getBudgets,
  );

  Future<void> close() => _changes.close();
}

Stream<List<BudgetModel>> _watchSnapshots({
  required Stream<Object?> changes,
  required Future<List<BudgetModel>> Function() load,
}) {
  late final StreamController<List<BudgetModel>> controller;
  late final StreamSubscription<Object?> subscription;

  Future<void> emitSnapshot() async {
    try {
      controller.add(await load());
    } on Object catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  controller = StreamController<List<BudgetModel>>(
    onListen: () {
      subscription = changes.listen(
        (_) => unawaited(emitSnapshot()),
        onError: controller.addError,
        onDone: controller.close,
      );
      unawaited(emitSnapshot());
    },
    onCancel: () => subscription.cancel(),
  );
  return controller.stream;
}
