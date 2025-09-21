// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfCacheModelAdapter extends TypeAdapter<PdfCacheModel> {
  @override
  final int typeId = 0;

  @override
  PdfCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfCacheModel(
      chapterId: fields[0] as String,
      pdfData: fields[1] as Uint8List,
      fileName: fields[2] as String,
      fileSize: fields[3] as int,
      cachedAt: fields[4] as DateTime,
      chapterTitle: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PdfCacheModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.pdfData)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.fileSize)
      ..writeByte(4)
      ..write(obj.cachedAt)
      ..writeByte(5)
      ..write(obj.chapterTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
