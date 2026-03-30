import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../domain/entities/feed_post.dart';
import '../controllers/feed_providers.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum FeedFilter { all, announcements, celebrations, updates }

// ── Filter state ──────────────────────────────────────────────────────────────

final feedFilterProvider =
    StateProvider<FeedFilter>((ref) => FeedFilter.all);

// ── Filtered posts ────────────────────────────────────────────────────────────

// NOTE: Existing FeedPost entity has no 'type' field — all posts render as
// message type. Filter chips are kept for UI completeness; they will be
// wired properly once the type column is added to the entity.
final filteredFeedPostsProvider = Provider<List<FeedPost>>((ref) {
  return ref.watch(feedPostsProvider).valueOrNull ?? [];
});

// ── Online presence ───────────────────────────────────────────────────────────

final onlineMembersProvider = StreamProvider<List<String>>((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  final supabase = ref.read(supabaseClientProvider);
  final currentUserId = supabase.auth.currentUser?.id;

  if (householdId == null || currentUserId == null) {
    return const Stream.empty();
  }

  final controller = StreamController<List<String>>.broadcast();
  final online = <String>{};

  final channel = supabase.channel('presence:$householdId');

  void syncOnline() {
    online.clear();
    for (final state in channel.presenceState()) {
      for (final presence in state.presences) {
        final uid = presence.payload['user_id'];
        if (uid is String) online.add(uid);
      }
    }
    if (!controller.isClosed) controller.add(online.toList());
  }

  channel
      .onPresenceSync((_) => syncOnline())
      .onPresenceJoin((_) => syncOnline())
      .onPresenceLeave((_) => syncOnline())
      .subscribe((status, [_]) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await channel.track({'user_id': currentUserId});
        }
      });

  ref.onDispose(() {
    supabase.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});

// ── Reactions ─────────────────────────────────────────────────────────────────

class Reaction {
  const Reaction({
    required this.id,
    required this.postId,
    required this.memberId,
    required this.emoji,
  });

  final String id;
  final String postId;
  final String memberId;
  final String emoji;

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        id: json['id'] as String,
        postId: json['post_id'] as String,
        memberId: json['member_id'] as String,
        emoji: json['emoji'] as String,
      );
}

final postReactionsProvider =
    FutureProvider.family<List<Reaction>, String>((ref, postId) async {
  final supabase = ref.read(supabaseClientProvider);
  final data = await supabase
      .from('feed_reactions')
      .select()
      .eq('post_id', postId);
  return (data as List).map((e) => Reaction.fromJson(e)).toList();
});

// ── Reaction actions ──────────────────────────────────────────────────────────

final reactionActionsProvider = Provider<ReactionActions>((ref) {
  return ReactionActions(ref.read(supabaseClientProvider));
});

class ReactionActions {
  ReactionActions(this._client);
  final SupabaseClient _client;

  Future<void> toggleReaction(
      String postId, String memberId, String emoji) async {
    final existing = await _client
        .from('feed_reactions')
        .select()
        .eq('post_id', postId)
        .eq('member_id', memberId)
        .eq('emoji', emoji)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('feed_reactions')
          .delete()
          .eq('id', existing['id'] as String);
    } else {
      await _client.from('feed_reactions').insert({
        'post_id': postId,
        'member_id': memberId,
        'emoji': emoji,
      });
    }
  }
}
