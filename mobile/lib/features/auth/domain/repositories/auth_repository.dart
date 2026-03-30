import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithMagicLink(String email);
  Future<void> signOut();
}
