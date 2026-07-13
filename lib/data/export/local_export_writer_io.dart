import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/entities/exported_file.dart';

class LocalExportWriter {
  const LocalExportWriter();

  Future<String> write(ExportedFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory('${directory.path}/masrofy_exports');
    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }
    final output = File('${exportDirectory.path}/${file.fileName}');
    await output.writeAsBytes(file.bytes, flush: true);
    return output.path;
  }
}
