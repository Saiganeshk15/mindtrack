import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login/login_screen.dart';
import '../home/home_screen.dart';
import 'services/user_service.dart';
import '../../core/services/journal_reminder_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          UserService.ensureUserExists();
          return const HomeScreen();
        }
        else {
          // ✅ User logged in → schedule reminders
          JournalReminderService.scheduleEveningReminders();
          return const LoginScreen();
        }
      },
    );
  }
}
