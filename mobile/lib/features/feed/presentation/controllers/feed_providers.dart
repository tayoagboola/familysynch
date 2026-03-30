import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../data/datasources/remote/feed_remote_datasource.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/repositories/feed_repository.dart';

part 'feed_providers.g.dart';

@riverpod
FeedRemoteDatasource feedRemoteDatasource(Ref ref) {
  return FeedRemoteDatasource(ref.watch(supabaseClientProvider));
}

@riverpod
FeedRepository feedRepository(Ref ref) {
  return FeedRepositoryImpl(ref.watch(feedRemoteDatasourceProvider));
}

@riverpod
Stream<List<FeedPost>> feedPosts(Ref ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();
  return ref.watch(feedRepositoryProvider).watchPosts(householdId);
}

@riverpod
class FeedActions extends _$FeedActions {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createPost({
    required String content,
    String? imageUrl,
  }) async {
    final householdId = ref.read(currentHouseholdIdProvider);
    if (householdId == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(feedRepositoryProvider)
        .createPost(
          householdId: householdId,
          content: content,
          imageUrl: imageUrl,
        ));
    return !state.hasError;
  }

  Future<bool> deletePost(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(feedRepositoryProvider).deletePost(id));
    return !state.hasError;
  }
}
