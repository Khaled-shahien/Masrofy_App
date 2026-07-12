import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A generated export artifact ready to save or share.
class ExportedFile extends Equatable {
  const ExportedFile({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  @override
  List<Object?> get props => [fileName, mimeType, bytes.length];
}
