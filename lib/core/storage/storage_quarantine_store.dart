import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

/// Stores sanitized records that failed validation.
class StorageQuarantineStore {
  StorageQuarantineStore(this._box);

  final Box<String> _box;

  Future<void> record({
    required String boxName,
    required String recordKey,
    required String errorCategory,
    required int migrationVersion,
    String? recordType,
  }) {
    final entry = <String, Object?>{
      'sourceBox': boxName,
      'recordKeyHash': _hash('$boxName:$recordKey'),
      'errorCategory': errorCategory,
      'migrationVersion': migrationVersion,
      'recordType': recordType ?? _recordTypeForBox(boxName),
      'recoverable': false,
      'recordedAt': DateTime.now().toIso8601String(),
    };
    final storageKey =
        '${_hash(boxName)}:${_hash(recordKey)}:${DateTime.now().microsecondsSinceEpoch}';
    return _box.put(storageKey, jsonEncode(entry));
  }

  int get count => _box.length;

  String _hash(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  String _recordTypeForBox(String boxName) {
    if (boxName.contains('transaction')) {
      return 'transaction';
    }
    if (boxName.contains('categor')) {
      return 'category';
    }
    if (boxName.contains('wallet')) {
      return 'walletBalance';
    }
    if (boxName.contains('budget')) {
      return 'budget';
    }
    if (boxName.contains('settings')) {
      return 'settings';
    }
    return 'unknown';
  }
}
