// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questions_database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionDatabaseAdapter extends TypeAdapter<QuestionDatabase> {
  @override
  final int typeId = 0;

  @override
  QuestionDatabase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionDatabase(
      question: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionDatabase obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.question);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionDatabaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
