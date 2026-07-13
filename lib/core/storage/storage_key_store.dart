import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Hive encryption key outside of Hive itself.
abstract interface class StorageKeyStore {
  Future<String?> readEncryptionKey();

  Future<void> saveEncryptionKey(String key);
}

enum StorageEncryptionFailureReason {
  unavailable,
  missingKeyForExistingData,
  invalidKey,
}

class StorageEncryptionException implements Exception {
  const StorageEncryptionException(this.reason, this.message);

  final StorageEncryptionFailureReason reason;
  final String message;

  @override
  String toString() => 'StorageEncryptionException($reason): $message';
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

  Future<Uint8List> readOrCreateKeyBytes({
    bool encryptedDataExists = false,
  }) async {
    final existing = await _readExistingKey();
    if (existing != null && existing.isNotEmpty) {
      try {
        final decoded = base64Decode(existing);
        if (decoded.length != 32) {
          throw const FormatException('Invalid Hive key length.');
        }
        return decoded;
      } on FormatException {
        throw const StorageEncryptionException(
          StorageEncryptionFailureReason.invalidKey,
          'The stored encryption key is invalid.',
        );
      }
    }

    if (encryptedDataExists) {
      throw const StorageEncryptionException(
        StorageEncryptionFailureReason.missingKeyForExistingData,
        'Encrypted local data exists but its secure storage key is missing.',
      );
    }

    final generated = _generateKeyBytes();
    try {
      await _keyStore.saveEncryptionKey(base64Encode(generated));
    } on Object {
      throw const StorageEncryptionException(
        StorageEncryptionFailureReason.unavailable,
        'Secure storage is unavailable for the local encryption key.',
      );
    }
    return generated;
  }

  Future<String?> _readExistingKey() async {
    try {
      return await _keyStore.readEncryptionKey();
    } on Object {
      throw const StorageEncryptionException(
        StorageEncryptionFailureReason.unavailable,
        'Secure storage is unavailable for the local encryption key.',
      );
    }
  }

  Uint8List _generateKeyBytes() {
    return Uint8List.fromList(
      List<int>.generate(32, (_) => _random.nextInt(256)),
    );
  }
}
