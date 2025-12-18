import '../../../core/services/supabase_service.dart';

class UserService {
  static Future<void> ensureUserExists() async {
    final client = SupabaseService.client;
    final user = client.auth.currentUser;

    if (user == null) return;

    final existing = await client
        .from('users')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing != null) return;

    await client.from('users').insert({
      'id': user.id,
      'email': user.email,
      'display_name': user.userMetadata?['full_name'],
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
