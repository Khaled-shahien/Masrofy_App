import '../../domain/entities/exported_file.dart';

class LocalExportWriter {
  const LocalExportWriter();

  Future<String> write(ExportedFile file) {
    throw UnsupportedError('Saving export files is not supported here.');
  }
}
