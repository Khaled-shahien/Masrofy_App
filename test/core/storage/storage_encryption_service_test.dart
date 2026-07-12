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
}
