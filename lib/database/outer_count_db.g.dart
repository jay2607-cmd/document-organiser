// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outer_count_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OuterCountAdapter extends TypeAdapter<OuterCount> {
  @override
  final int typeId = 0;

  @override
  OuterCount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OuterCount(
      count: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OuterCount obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OuterCountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
