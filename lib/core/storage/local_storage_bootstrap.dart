import 'package:hive_flutter/hive_flutter.dart';

import 'migrations/storage_migration_manager.dart';
import 'storage_key_store.dart';
import 'storage_quarantine_store.dart';
import 'storage_schema.dart';

class LocalStorageBootstrapResult {
  const LocalStorageBootstrapResult({
    required this.existingInstallation,
  });

  final bool existingInstallation;
}

/// Prepares the local persistence required before the application starts.
class LocalStorageBootstrap {
  const LocalStorageBootstrap._();

  /// The current Hive box containing category JSON records.
  static const categoriesBoxName = StorageSchema.categoriesBoxName;

  /// The current Hive box containing transaction JSON records.
  static const transactionsBoxName = StorageSchema.transactionsBoxName;

  /// The current Hive box containing user preference records.
  static const settingsBoxName = StorageSchema.settingsBoxName;

  /// The current Hive box containing wallet balance records.
  static const walletBalancesBoxName = StorageSchema.walletBalancesBoxName;

  /// The current Hive box containing monthly budget records.
  static const budgetsBoxName = StorageSchema.budgetsBoxName;

  /// The metadata box containing the stored storage schema version.
  static const metadataBoxName = StorageSchema.metadataBoxName;

  /// The quarantine box used for unreadable records.
  static const quarantineBoxName = StorageSchema.quarantineBoxName;

  /// Initializes Hive and opens boxes required during application startup.
  static Future<LocalStorageBootstrapResult> initialize({
    StorageKeyStore? keyStore,
  }) async {
    await Hive.initFlutter();

    final encryptedDataExists = await _encryptedDataExists();
    final existingInstallation =
        encryptedDataExists ||
        await Hive.boxExists(StorageSchema.metadataBoxName) ||
        await Hive.boxExists(StorageSchema.legacyCategoriesBoxName) ||
        await Hive.boxExists(StorageSchema.legacyTransactionsBoxName) ||
        await Hive.boxExists(StorageSchema.legacySettingsBoxName) ||
        await Hive.boxExists(StorageSchema.legacyWalletBalancesBoxName);

    await Hive.openBox<String>(metadataBoxName);
    await Hive.openBox<String>(StorageSchema.legacyQuarantineBoxName);
    await Hive.openBox<String>(StorageSchema.legacyCategoriesBoxName);
    await Hive.openBox<String>(StorageSchema.legacyTransactionsBoxName);
    await Hive.openBox<String>(StorageSchema.legacySettingsBoxName);
    await Hive.openBox<String>(StorageSchema.legacyWalletBalancesBoxName);

    final encryptionService = StorageEncryptionService(
      keyStore ?? FlutterSecureStorageKeyStore(),
    );
    final cipher = HiveAesCipher(
      await encryptionService.readOrCreateKeyBytes(
        encryptedDataExists: encryptedDataExists,
      ),
    );
    await Hive.openBox<String>(quarantineBoxName, encryptionCipher: cipher);

    final migrationManager = StorageMigrationManager(
      encryptionService: encryptionService,
      encryptedDataExists: encryptedDataExists,
      quarantineStore: StorageQuarantineStore(
        Hive.box<String>(quarantineBoxName),
      ),
      legacyQuarantineBox: Hive.box<String>(
        StorageSchema.legacyQuarantineBoxName,
      ),
      metadataBox: Hive.box<String>(metadataBoxName),
    );

    final result = await migrationManager.migrate();
    if (!result.success) {
      throw StateError(
        result.failureMessage ?? 'Failed to initialize local storage.',
      );
    }
    return LocalStorageBootstrapResult(
      existingInstallation: existingInstallation,
    );
  }

  static Future<bool> _encryptedDataExists() async {
    for (final boxName in [
      StorageSchema.categoriesBoxName,
      StorageSchema.transactionsBoxName,
      StorageSchema.settingsBoxName,
      StorageSchema.walletBalancesBoxName,
      StorageSchema.budgetsBoxName,
      StorageSchema.quarantineBoxName,
    ]) {
      if (Hive.isBoxOpen(boxName) || await Hive.boxExists(boxName)) {
        return true;
      }
    }
    return false;
  }
}
