import '../entities/journal_entry.dart';
import '../entities/journal_insight.dart';

class AggregateJournalInsightsUseCase {
  JournalInsight aggregateWeekly(List<JournalEntry> entries) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));

    final Map<String, int> counts = {};

    for (final entry in entries) {
      if (entry.date.isBefore(start)) continue;

      final category = entry.category ?? 'neutral';
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return JournalInsight(
      startDate: start,
      endDate: now,
      categoryCounts: counts,
    );
  }
}
