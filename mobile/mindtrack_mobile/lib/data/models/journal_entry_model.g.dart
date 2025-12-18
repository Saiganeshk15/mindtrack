// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntryModelAdapter extends TypeAdapter<JournalEntryModel> {
  @override
  final int typeId = 1;

  @override
  JournalEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntryModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      content: fields[2] as String,
      wordCount: fields[3] as int,
      category: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.wordCount)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
