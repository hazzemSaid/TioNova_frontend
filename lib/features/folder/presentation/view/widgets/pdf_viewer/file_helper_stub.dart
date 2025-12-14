import 'dart:typed_data';

/// Stub implementation for web - file operations are not supported.
Future<void> writeFileBytes(String path, Uint8List bytes) async {
  throw UnsupportedError('File operations not supported on web');
}

/// Stub implementation for web - file operations are not supported.
void deleteFile(String path) {
  // No-op on web
}
