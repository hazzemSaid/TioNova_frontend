// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SummaryCacheModelAdapter extends TypeAdapter<SummaryCacheModel> {
  @override
  final int typeId = 2;

  @override
  SummaryCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SummaryCacheModel(
      chapterId: fields[0] as String,
      summaryDataJson: fields[1] as String,
      cachedAt: fields[2] as DateTime,
      chapterTitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SummaryCacheModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.summaryDataJson)
      ..writeByte(2)
      ..write(obj.cachedAt)
      ..writeByte(3)
      ..write(obj.chapterTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
