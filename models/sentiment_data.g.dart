// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentiment_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SentimentDataAdapter extends TypeAdapter<SentimentData> {
  @override
  final int typeId = 2;

  @override
  SentimentData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SentimentData(
      sentimentId: fields[0] as String,
      time: fields[1] as DateTime,
      score: fields[2] as double,
      prompt: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SentimentData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sentimentId)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.prompt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SentimentDataAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}