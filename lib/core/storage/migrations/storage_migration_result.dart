/// Outcome of a storage migration run.
class StorageMigrationResult {
  const StorageMigrationResult({
    required this.success,
    required this.storedSchemaVersion,
    required this.targetSchemaVersion,
    required this.appliedMigrations,
    required this.quarantinedRecordCount,
    this.failureMessage,
  });

  final bool success;
  final int storedSchemaVersion;
  final int targetSchemaVersion;
  final List<String> appliedMigrations;
  final int quarantinedRecordCount;
  final String? failureMessage;
}
