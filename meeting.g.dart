// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MettingAdapter extends TypeAdapter<Meeting> {
  @override
  final int typeId = 0;

  @override
  Meeting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meeting(
      fields[0] as String,
      fields[1] as DateTime,
      fields[2] as DateTime,
      fields[3] as int,
      fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Meeting obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.eventName)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.to)
      ..writeByte(3)
      ..write(obj.background)
      ..writeByte(4)
      ..write(obj.isAllDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
