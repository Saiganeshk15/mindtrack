import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../data/local/journal_local_datasource.dart';

class JournalMetadataSyncService {
  static const _storage = FlutterSecureStorage();
  static const _lastSyncKey = 'last_metadata_sync_at';
  static const _lastJournalUpdateKey = 'last_journal_update_at';

  static Future<void> syncIfNeeded({bool force = false}) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    final lastSyncRaw = await _storage.read(key: _lastSyncKey);
    final lastUpdateRaw = await _storage.read(key: _lastJournalUpdateKey);

    final lastSync =
    lastSyncRaw != null ? DateTime.parse(lastSyncRaw) : null;
    final lastUpdate =
    lastUpdateRaw != null ? DateTime.parse(lastUpdateRaw) : null;

    // 🛑 No new local changes → no sync needed
    if (!force &&
        lastSync != null &&
        lastUpdate != null &&
        !lastUpdate.isAfter(lastSync)) {
      return;
    }

    // ⛔ Enforce 3-day hard limit
    if (!force &&
        lastSync != null &&
        now.difference(lastSync).inDays < 3 &&
        lastUpdate == null) {
      return;
    }

    final repo = JournalRepositoryImpl(JournalLocalDatasource());
    final entries = await repo.getEntries();

    for (final entry in entries) {
      await client.from('journal_metadata').upsert({
        'user_id': user.id,
        'entry_date': entry.date.toIso8601String().split('T').first,
        'word_count': entry.wordCount,
        'category': entry.category,
      });
    }

    await _storage.write(
      key: _lastSyncKey,
      value: now.toIso8601String(),
    );
  }
}
