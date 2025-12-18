import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/journal_repository_impl.dart';
import '../../../data/local/journal_local_datasource.dart';
import '../../../domain/entities/journal_entry.dart';

final journalProvider =
StateNotifierProvider<JournalNotifier, JournalState>(
      (ref) => JournalNotifier(),
);

class JournalState {
  final String content;
  final int wordCount;
  final bool canSave;
  final bool isExisting;
  final bool isLocked;
  final String category;

  JournalState({
    this.content = '',
    this.wordCount = 0,
    this.canSave = false,
    this.isExisting = false,
    this.isLocked = false,
    this.category = 'neutral',
  });
}

class JournalNotifier extends StateNotifier<JournalState> {
  final _repo =
  JournalRepositoryImpl(JournalLocalDatasource());

  JournalNotifier() : super(JournalState()) {
    loadToday();
  }

  Future<void> loadToday() async {
    final entry = await _repo.getTodayEntry();

    if (entry == null) {
      // No journal yet today → fresh editable state
      state = JournalState(
        content: '',
        wordCount: 0,
        canSave: false,
        isExisting: false,
        isLocked: false,
        category: 'neutral',
      );
      return;
    }

    // Journal exists → read-only (free user)
    state = JournalState(
      content: entry.content,
      wordCount: entry.wordCount,
      canSave: false,
      isExisting: true,
      isLocked: true,
      category: entry.category ?? 'neutral',
    );
  }

  void updateContent(String text) {
    if (state.isLocked) return;

    final words =
    text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

    state = JournalState(
      content: text,
      wordCount: words,
      canSave: text.length >= 30,
      isExisting: state.isExisting,
      isLocked: false,
    );
  }

  Future<void> saveToday() async {
    final existing = await _repo.getTodayEntry();

    final entry = JournalEntry(
      id: existing?.id ?? const Uuid().v4(),
      date: DateTime.now(),
      content: state.content,
      wordCount: state.wordCount,
      // ❌ no category here
    );

    final savedEntry = await _repo.saveEntry(entry);

    state = JournalState(
      content: savedEntry.content,
      wordCount: savedEntry.wordCount,
      canSave: false,
      isExisting: true,
      isLocked: true,
      category: savedEntry.category ?? 'neutral',
    );
  }
}
