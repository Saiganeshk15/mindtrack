import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/journal_entry_model.dart';
import '../../core/services/journal_reminder_service.dart';


class JournalLocalDatasource {
  static const _boxName = 'journals';
  static const _lastJournalUpdateKey = 'last_journal_update_at';
  final _secureStorage = const FlutterSecureStorage();

  Future<Box<JournalEntryModel>> _openBox() async {
    return Hive.openBox<JournalEntryModel>(_boxName);
  }

  Future<void> save(JournalEntryModel entry) async {
    final box = await _openBox();
    await box.put(entry.id, entry);

    await _secureStorage.write(
      key: _lastJournalUpdateKey,
      value: DateTime.now().toIso8601String(),
    );

    // ✅ stop reminders for today
    await JournalReminderService.cancelAll();
  }

  Future<List<JournalEntryModel>> getAll() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> delete(String id) async {
    final box = await _openBox();
    await box.delete(id);

    await _secureStorage.write(
      key: _lastJournalUpdateKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<JournalEntryModel?> getByDate(DateTime date) async {
    final box = await _openBox();

    final normalized = DateTime(date.year, date.month, date.day);

    for (final entry in box.values) {
      final entryDate =
      DateTime(entry.date.year, entry.date.month, entry.date.day);

      if (entryDate == normalized) {
        return entry;
      }
    }
    return null;
  }

  Future<List<JournalEntryModel>> getLastNDays(int days) async {
    final box = await _openBox();
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return box.values
        .where((e) => e.date.isAfter(cutoff))
        .toList();
  }
}

