class JournalInsight {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, int> categoryCounts;

  JournalInsight({
    required this.startDate,
    required this.endDate,
    required this.categoryCounts,
  });
}
