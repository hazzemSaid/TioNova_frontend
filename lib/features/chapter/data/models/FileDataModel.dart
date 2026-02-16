import 'dart:typed_data';

class FileData {
  final Uint8List bytes;
  final String filename;
  final String? mimeType;

  FileData({required this.bytes, required this.filename, this.mimeType});
}
