import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../domain/entities/wallet_type.dart';
import '../../models/wallet_balance_model.dart';

abstract interface class WalletBalanceLocalDataSource {
  Stream<List<WalletBalanceModel>> watchWalletBalances();

  Future<List<WalletBalanceModel>> getWalletBalances();

  Future<WalletBalanceModel?> getWalletBalance(WalletType walletType);

  Future<void> saveWalletBalance(WalletBalanceModel balance);

  Future<void> replaceWalletBalances(Iterable<WalletBalanceModel> balances);
}

class HiveWalletBalanceLocalDataSource implements WalletBalanceLocalDataSource {
  const HiveWalletBalanceLocalDataSource(this._box);

  final Box<String> _box;

  @override
  Future<List<WalletBalanceModel>> getWalletBalances() async {
    return _box.values.map(_decode).toList(growable: false);
  }

  @override
  Future<WalletBalanceModel?> getWalletBalance(WalletType walletType) async {
    final encoded = _box.get(walletType.name);
    return encoded == null ? null : _decode(encoded);
  }

  @override
  Future<void> saveWalletBalance(WalletBalanceModel balance) {
    return _box.put(balance.walletType.name, jsonEncode(balance.toJson()));
  }

  @override
  Future<void> replaceWalletBalances(
    Iterable<WalletBalanceModel> balances,
  ) async {
    await _box.clear();
    await _box.putAll(<String, String>{
      for (final balance in balances)
        balance.walletType.name: jsonEncode(balance.toJson()),
    });
  }

  @override
  Stream<List<WalletBalanceModel>> watchWalletBalances() =>
      _watchSnapshots(changes: _box.watch(), load: getWalletBalances);

  WalletBalanceModel _decode(String value) {
    final decoded = jsonDecode(value);
    return switch (decoded) {
      Map<String, dynamic> json => WalletBalanceModel.fromJson(json),
      _ => throw const FormatException(
        'Stored wallet balance must be a JSON map.',
      ),
    };
  }
}

class InMemoryWalletBalanceLocalDataSource
    implements WalletBalanceLocalDataSource {
  InMemoryWalletBalanceLocalDataSource([
    Iterable<WalletBalanceModel> seed = const [],
  ]) : _records = {for (final balance in seed) balance.walletType: balance};

  final Map<WalletType, WalletBalanceModel> _records;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  @override
  Future<List<WalletBalanceModel>> getWalletBalances() async {
    return List<WalletBalanceModel>.unmodifiable(_records.values);
  }

  @override
  Future<WalletBalanceModel?> getWalletBalance(WalletType walletType) async {
    return _records[walletType];
  }

  @override
  Future<void> saveWalletBalance(WalletBalanceModel balance) async {
    _records[balance.walletType] = balance;
    _changes.add(null);
  }

  @override
  Future<void> replaceWalletBalances(
    Iterable<WalletBalanceModel> balances,
  ) async {
    _records
      ..clear()
      ..addAll({for (final balance in balances) balance.walletType: balance});
    _changes.add(null);
  }

  @override
  Stream<List<WalletBalanceModel>> watchWalletBalances() =>
      _watchSnapshots(changes: _changes.stream, load: getWalletBalances);

  Future<void> close() => _changes.close();
}

Stream<List<WalletBalanceModel>> _watchSnapshots({
  required Stream<Object?> changes,
  required Future<List<WalletBalanceModel>> Function() load,
}) {
  late final StreamController<List<WalletBalanceModel>> controller;
  late final StreamSubscription<Object?> subscription;

  Future<void> emitSnapshot() async {
    try {
      controller.add(await load());
    } on Object catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  controller = StreamController<List<WalletBalanceModel>>(
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
