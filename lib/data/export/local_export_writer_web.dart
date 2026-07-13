// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import '../../domain/entities/exported_file.dart';

class LocalExportWriter {
  const LocalExportWriter();

  Future<String> write(ExportedFile file) async {
    final blob = html.Blob(<Object>[file.bytes], file.mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    try {
      html.AnchorElement(href: url)
        ..download = file.fileName
        ..click();
    } finally {
      html.Url.revokeObjectUrl(url);
    }
    return file.fileName;
  }
}
