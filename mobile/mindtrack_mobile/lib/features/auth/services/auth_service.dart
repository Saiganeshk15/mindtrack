import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: '823196332750-rpuop121rs4t1j377dob0b2hkspmb67j.apps.googleusercontent.com',
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null || accessToken == null) {
      throw Exception('Missing Google Auth Token');
    }

    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
