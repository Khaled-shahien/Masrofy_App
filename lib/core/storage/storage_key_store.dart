import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Hive encryption key outside of Hive itself.
abstract interface class StorageKeyStore {
  Future<String?> readEncryptionKey();

  Future<void> saveEncryptionKey(String key);
}

/// Stores the encryption key in platform secure storage.
class FlutterSecureStorageKeyStore implements StorageKeyStore {
  FlutterSecureStorageKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _encryptionKeyName = 'hive_encryption_key_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readEncryptionKey() {
    return _storage.read(key: _encryptionKeyName);
  }

  @override
  Future<void> saveEncryptionKey(String key) {
    return _storage.write(key: _encryptionKeyName, value: key);
  }
}

/// In-memory key storage used by tests.
class InMemoryStorageKeyStore implements StorageKeyStore {
  String? _key;

  @override
  Future<String?> readEncryptionKey() async => _key;

  @override
  Future<void> saveEncryptionKey(String key) async {
    _key = key;
  }
}

/// Generates and persists the Hive AES key.
class StorageEncryptionService {
  StorageEncryptionService(this._keyStore, {Random? random})
    : _random = random ?? Random.secure();

  final StorageKeyStore _keyStore;
  final Random _random;

  Future<Uint8List> readOrCreateKeyBytes() async {
    final existing = await _keyStore.readEncryptionKey();
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }

    final generated = _generateKeyBytes();
    await _keyStore.saveEncryptionKey(base64Encode(generated));
    return generated;
  }

  Uint8List _generateKeyBytes() {
    return Uint8List.fromList(
      List<int>.generate(32, (_) => _random.nextInt(256)),
    );
  }
}
