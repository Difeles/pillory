import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/backup_format.dart';

/// Where backup files come from and go to: the system's file dialogs.
abstract class BackupFiles {
  /// False if the user cancelled.
  Future<bool> save(String fileName, Uint8List bytes);

  /// Null if the user cancelled. Throws [BackupException] for a file over
  /// [maxBackupBytes], before it is read.
  Future<Uint8List?> pick();
}

class FilePickerBackupFiles implements BackupFiles {
  const FilePickerBackupFiles();

  @override
  Future<bool> save(String fileName, Uint8List bytes) async =>
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/json',
      ) !=
      null;

  @override
  Future<Uint8List?> pick() async {
    // Any type: the custom extension is not known to the system pickers.
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    if ((await file.length() ?? 0) > maxBackupBytes) {
      throw const BackupException(
        BackupProblem.tooLarge,
        'Файл слишком большой для резервной копии Pillory',
      );
    }
    return file.readAsBytes();
  }
}

final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const FilePickerBackupFiles(),
);
