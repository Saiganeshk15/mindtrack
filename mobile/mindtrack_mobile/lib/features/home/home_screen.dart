import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: AuthService.signOut,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.email ?? ''}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
