import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/services/timezone_service.dart';
import 'core/services/journal_reminder_service.dart';
import 'features/auth/auth_gate.dart';
import 'core/config/app_theme.dart';
import 'data/models/journal_entry_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone (required for scheduling)
  TimezoneService.init();

  // Request notification permission (Android 13+)
  await Permission.notification.request();

  // Initialize notifications
  await JournalReminderService.init();

  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryModelAdapter());

  await Supabase.initialize(
    url: 'https://yavcbnxhfrwzfgxbpxyg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhdmNibnhoZnJ3emZneGJweHlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1MjE4NjMsImV4cCI6MjA4MTA5Nzg2M30.Du44FaUXP793aTNKA34Y7hGTIn7_ZObfILKjPrUYWNk',
  );

  runApp(const MindTrackApp());
}

class MindTrackApp extends StatelessWidget {
  const MindTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
