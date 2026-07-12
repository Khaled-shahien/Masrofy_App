import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import '../../models/financial_transaction_model.dart';

abstract interface class TransactionLocalDataSource {
  Stream<List<FinancialTransactionModel>> watchTransactions();

  Future<List<FinancialTransactionModel>> getTransactions();

  Future<void> saveTransaction(FinancialTransactionModel transaction);

  Future<void> deleteTransaction(String id);

  Future<void> replaceTransactions(
    Iterable<FinancialTransactionModel> transactions,
  );
}

class HiveTransactionLocalDataSource implements TransactionLocalDataSource {
  const HiveTransactionLocalDataSource(this._box);

  final Box<String> _box;

  @override
  Future<List<FinancialTransactionModel>> getTransactions() async {
    return _box.values.map(_decode).toList(growable: false);
  }

  @override
  Future<void> saveTransaction(FinancialTransactionModel transaction) {
    return _box.put(transaction.id, jsonEncode(transaction.toJson()));
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _box.delete(id);
  }

  @override
  Future<void> replaceTransactions(
    Iterable<FinancialTransactionModel> transactions,
  ) async {
    await _box.clear();
    await _box.putAll(<String, String>{
      for (final transaction in transactions)
        transaction.id: jsonEncode(transaction.toJson()),
    });
  }

  @override
  Stream<List<FinancialTransactionModel>> watchTransactions() =>
      _watchSnapshots(changes: _box.watch(), load: getTransactions);

  FinancialTransactionModel _decode(String value) {
    final decoded = jsonDecode(value);
    return switch (decoded) {
      Map<String, dynamic> json => FinancialTransactionModel.fromJson(json),
      _ => throw const FormatException(
        'Stored transaction must be a JSON map.',
      ),
    };
  }
}

class InMemoryTransactionLocalDataSource implements TransactionLocalDataSource {
  InMemoryTransactionLocalDataSource([
    Iterable<FinancialTransactionModel> seed = const [],
  ]) : _records = {for (final transaction in seed) transaction.id: transaction};

  final Map<String, FinancialTransactionModel> _records;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  @override
  Future<List<FinancialTransactionModel>> getTransactions() async {
    return List<FinancialTransactionModel>.unmodifiable(_records.values);
  }

  @override
  Future<void> saveTransaction(FinancialTransactionModel transaction) async {
    _records[transaction.id] = transaction;
    _changes.add(null);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _records.remove(id);
    _changes.add(null);
  }

  @override
  Future<void> replaceTransactions(
    Iterable<FinancialTransactionModel> transactions,
  ) async {
    _records
      ..clear()
      ..addAll({
        for (final transaction in transactions) transaction.id: transaction,
      });
    _changes.add(null);
  }

  @override
  Stream<List<FinancialTransactionModel>> watchTransactions() =>
      _watchSnapshots(changes: _changes.stream, load: getTransactions);

  Future<void> close() => _changes.close();
}

Stream<List<FinancialTransactionModel>> _watchSnapshots({
  required Stream<Object?> changes,
  required Future<List<FinancialTransactionModel>> Function() load,
}) {
  late final StreamController<List<FinancialTransactionModel>> controller;
  late final StreamSubscription<Object?> subscription;

  Future<void> emitSnapshot() async {
    try {
      controller.add(await load());
    } on Object catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  controller = StreamController<List<FinancialTransactionModel>>(
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
