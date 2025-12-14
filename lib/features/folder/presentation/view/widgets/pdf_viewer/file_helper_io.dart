import 'dart:io';
import 'dart:typed_data';

/// Write bytes to a file at the given path.
Future<void> writeFileBytes(String path, Uint8List bytes) async {
  final file = File(path);
  await file.writeAsBytes(bytes);
}

/// Delete a file at the given path.
void deleteFile(String path) {
  try {
    final file = File(path);
    file.delete().catchError((e) {
      // Ignore deletion errors
      return file;
    });
  } catch (e) {
    // Ignore errors
  }
}
