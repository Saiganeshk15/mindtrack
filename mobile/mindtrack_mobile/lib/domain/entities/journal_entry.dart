class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final int wordCount;
  final String? category;

  JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.wordCount,
    this.category,
  });

  JournalEntry copyWith({
    String? category,
  }) {
    return JournalEntry(
      id: id,
      date: date,
      content: content,
      wordCount: wordCount,
      category: category ?? this.category,
    );
  }
}
