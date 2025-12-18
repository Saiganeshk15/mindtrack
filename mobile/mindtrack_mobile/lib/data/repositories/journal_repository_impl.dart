import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../local/journal_local_datasource.dart';
import '../models/journal_entry_model.dart';
import '../../domain/usecases/detect_journal_category_usecase.dart';
import '../../domain/usecases/aggregate_journal_insights_usecase.dart';
import '../../domain/entities/journal_insight.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDatasource local;

  JournalRepositoryImpl(this.local);

  @override
  Future<JournalEntry> saveEntry(JournalEntry entry) async {
    final detector = DetectJournalCategoryUseCase();

    final category = detector.detect(entry.content);

    final updated = entry.copyWith(category: category);

    await local.save(JournalEntryModel.fromEntity(updated));

    return updated; // authoritative
  }

  @override
  Future<List<JournalEntry>> getEntries() async {
    final models = await local.getAll();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    await local.delete(id);
  }

  @override
  Future<JournalEntry?> getTodayEntry() async {
    final model = await local.getByDate(DateTime.now());
    return model?.toEntity();
  }

  @override
  Future<JournalInsight> getWeeklyInsight() async {
    final models = await local.getLastNDays(7);

    final entries = models.map((m) => m.toEntity()).toList();

    final aggregator = AggregateJournalInsightsUseCase();

    return aggregator.aggregateWeekly(entries);
  }
}
