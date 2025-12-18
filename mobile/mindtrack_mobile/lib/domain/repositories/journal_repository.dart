import '../entities/journal_entry.dart';
import '../entities/journal_insight.dart';

abstract class JournalRepository {
  Future<void> saveEntry(JournalEntry entry);
  Future<List<JournalEntry>> getEntries();
  Future<void> deleteEntry(String id);
  Future<JournalEntry?> getTodayEntry();
  Future<JournalInsight> getWeeklyInsight();
}
