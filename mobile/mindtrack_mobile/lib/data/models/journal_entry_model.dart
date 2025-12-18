import 'package:hive/hive.dart';
import '../../domain/entities/journal_entry.dart';

part 'journal_entry_model.g.dart';

@HiveType(typeId: 1)
class JournalEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final int wordCount;

  @HiveField(4)
  final String category;

  JournalEntryModel({
    required this.id,
    required this.date,
    required this.content,
    required this.wordCount,
    required this.category,
  });

  factory JournalEntryModel.fromEntity(JournalEntry entity) {
    return JournalEntryModel(
      id: entity.id,
      date: entity.date,
      content: entity.content,
      wordCount: entity.wordCount,
      category: entity.category ?? 'neutral',
    );
  }

  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      date: date,
      content: content,
      wordCount: wordCount,
      category: category,
    );
  }
}
