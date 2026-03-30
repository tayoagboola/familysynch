import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/providers/supabase_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_notifier.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
}

@riverpod
Stream<User?> authUser(AuthUserRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  return ref.watch(authUserProvider).valueOrNull != null;
}

@riverpod
class AuthActions extends _$AuthActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithApple(),
    );
  }

  Future<void> signInWithMagicLink(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithMagicLink(email),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
