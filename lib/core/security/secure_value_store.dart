import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small abstraction over platform secure storage for security-sensitive values.
abstract interface class SecureValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Secure storage backed by the platform keychain/keystore where available.
class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final Map<String, String> _fallbackValues = <String, String>{};

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return _fallbackValues[key];
    } on PlatformException {
      return _fallbackValues[key];
    }
  }

  @override
  Future<void> write(String key, String value) {
    return _write(key, value);
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      _fallbackValues.remove(key);
    } on PlatformException {
      _fallbackValues.remove(key);
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      _fallbackValues[key] = value;
    } on PlatformException {
      _fallbackValues[key] = value;
    }
  }
}

/// In-memory secure storage used by tests and previews.
class InMemorySecureValueStore implements SecureValueStore {
  final Map<String, String> _values = <String, String>{};

  Map<String, String> get debugValues =>
      Map<String, String>.unmodifiable(_values);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
