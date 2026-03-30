import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((e) => e.session?.user);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'familysync://auth/callback',
    );
  }

  @override
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'familysync://auth/callback',
    );
  }

  @override
  Future<void> signInWithMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'familysync://auth/callback',
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
