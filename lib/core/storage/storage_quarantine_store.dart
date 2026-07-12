import 'dart:convert';

import 'package:hive/hive.dart';

/// Stores quarantined raw records that failed validation.
class StorageQuarantineStore {
  StorageQuarantineStore(this._box);

  final Box<String> _box;

  Future<void> record({
    required String boxName,
    required String recordKey,
    required String rawValue,
    required String reason,
  }) {
    final entry = <String, Object?>{
      'boxName': boxName,
      'recordKey': recordKey,
      'rawValue': rawValue,
      'reason': reason,
      'recordedAt': DateTime.now().toIso8601String(),
    };
    final storageKey =
        '$boxName:$recordKey:${DateTime.now().microsecondsSinceEpoch}';
    return _box.put(storageKey, jsonEncode(entry));
  }

  int get count => _box.length;
}
