import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/storage/storage_key_store.dart';

void main() {
  test('generates and reuses a persisted encryption key', () async {
    final keyStore = InMemoryStorageKeyStore();
    final service = StorageEncryptionService(keyStore);

    final first = await service.readOrCreateKeyBytes();
    final second = await service.readOrCreateKeyBytes();

    expect(first, hasLength(32));
    expect(second, equals(first));
    expect(await keyStore.readEncryptionKey(), isNotNull);
  });

  test('fails closed when encrypted data exists without a key', () async {
    final service = StorageEncryptionService(InMemoryStorageKeyStore());

    expect(
      () => service.readOrCreateKeyBytes(encryptedDataExists: true),
      throwsA(
        isA<StorageEncryptionException>().having(
          (error) => error.reason,
          'reason',
          StorageEncryptionFailureReason.missingKeyForExistingData,
        ),
      ),
    );
  });

  test('rejects malformed persisted encryption keys', () async {
    final keyStore = InMemoryStorageKeyStore();
    await keyStore.saveEncryptionKey('not-base64');
    final service = StorageEncryptionService(keyStore);

    expect(
      service.readOrCreateKeyBytes,
      throwsA(
        isA<StorageEncryptionException>().having(
          (error) => error.reason,
          'reason',
          StorageEncryptionFailureReason.invalidKey,
        ),
      ),
    );
  });
}
