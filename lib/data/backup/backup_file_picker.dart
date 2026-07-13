import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

class PickedBackupFile extends Equatable {
  const PickedBackupFile({
    required this.name,
    required this.bytes,
    required this.size,
    this.path,
  });

  final String name;
  final Uint8List bytes;
  final int size;
  final String? path;

  @override
  List<Object?> get props => [name, bytes.length, size, path];
}

enum BackupFilePickerFailureReason { invalidExtension, emptyFile, tooLarge }

class BackupFilePickerException implements Exception {
  const BackupFilePickerException(this.reason);

  final BackupFilePickerFailureReason reason;
}

abstract interface class BackupFilePicker {
  Future<PickedBackupFile?> pickBackupFile();
}

class PlatformBackupFilePicker implements BackupFilePicker {
  const PlatformBackupFilePicker({
    FilePicker? filePicker,
    int maxBytes = 10 * 1024 * 1024,
  }) : _filePicker = filePicker,
       _maxBytes = maxBytes;

  final FilePicker? _filePicker;
  final int _maxBytes;

  @override
  Future<PickedBackupFile?> pickBackupFile() async {
    final result = await (_filePicker ?? FilePicker.platform).pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final name = file.name;
    if (!name.toLowerCase().endsWith('.json')) {
      throw const BackupFilePickerException(
        BackupFilePickerFailureReason.invalidExtension,
      );
    }
    if (file.size <= 0) {
      throw const BackupFilePickerException(
        BackupFilePickerFailureReason.emptyFile,
      );
    }
    if (file.size > _maxBytes) {
      throw const BackupFilePickerException(
        BackupFilePickerFailureReason.tooLarge,
      );
    }
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const BackupFilePickerException(
        BackupFilePickerFailureReason.emptyFile,
      );
    }
    return PickedBackupFile(
      name: name,
      bytes: bytes,
      size: file.size,
      path: file.path,
    );
  }
}

class InMemoryBackupFilePicker implements BackupFilePicker {
  InMemoryBackupFilePicker([this.nextFile]);

  PickedBackupFile? nextFile;

  @override
  Future<PickedBackupFile?> pickBackupFile() async => nextFile;
}
