import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/providers/household_providers.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../data/ai_repository.dart';

// ── ChatMessage Model ─────────────────────────────────────────────────────────

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isWelcome = false,
  });

  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isWelcome;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

// ── AINotification Model ──────────────────────────────────────────────────────

class AINotification {
  const AINotification({
    required this.id,
    required this.householdId,
    required this.targetMemberId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String householdId;
  final String targetMemberId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  factory AINotification.fromJson(Map<String, dynamic> json) => AINotification(
        id: json['id'] as String,
        householdId: json['household_id'] as String,
        targetMemberId: json['target_member_id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: (json['type'] as String?) ?? 'reminder',
        isRead: (json['is_read'] as bool?) ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// ── Chat Messages Notifier ────────────────────────────────────────────────────

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier()
      : super([
          ChatMessage(
            role: 'assistant',
            content:
                "Hey! 👋 I'm FamilyAI. I've synced with your family's data. What would you like to know?",
            timestamp: DateTime.now(),
            isWelcome: true,
          ),
        ]);

  void addUserMessage(String text) {
    state = [
      ...state,
      ChatMessage(
          role: 'user', content: text, timestamp: DateTime.now()),
    ];
  }

  void addAIMessage(String text) {
    state = [
      ...state,
      ChatMessage(
          role: 'assistant', content: text, timestamp: DateTime.now()),
    ];
  }

  void clear() {
    state = [state.first]; // keep welcome message
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
        (ref) => ChatMessagesNotifier());

// ── Typing State ──────────────────────────────────────────────────────────────

final isAITypingProvider = StateProvider<bool>((ref) => false);

// ── Active Context ────────────────────────────────────────────────────────────

final activeContextProvider = StateProvider<Set<String>>(
    (ref) => {'calendar', 'tasks', 'grocery'});

// ── Nudges ────────────────────────────────────────────────────────────────────

final nudgesProvider = StreamProvider<List<AINotification>>((ref) {
  final householdId = ref.watch(currentHouseholdIdProvider);
  if (householdId == null) return const Stream.empty();
  final supabase = ref.read(supabaseClientProvider);
  final currentUserId = supabase.auth.currentUser?.id;
  if (currentUserId == null) return const Stream.empty();

  return supabase
      .from('ai_notifications')
      .stream(primaryKey: ['id'])
      .eq('household_id', householdId)
      .order('created_at', ascending: false)
      .map((rows) => rows
          .where((r) =>
              r['is_read'] == false &&
              r['target_member_id'] == currentUserId)
          .map(AINotification.fromJson)
          .toList());
});

final nudgeCountProvider = Provider<int>((ref) {
  return ref.watch(nudgesProvider).valueOrNull?.length ?? 0;
});

final latestNudgeProvider = Provider<AINotification?>((ref) {
  final nudges = ref.watch(nudgesProvider).valueOrNull ?? [];
  return nudges.isNotEmpty ? nudges.first : null;
});

// ── AI Repository Provider ────────────────────────────────────────────────────

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepository(ref.read(supabaseClientProvider));
});

// ── Nudge Actions ─────────────────────────────────────────────────────────────

final nudgeActionsProvider = Provider<NudgeActions>((ref) {
  return NudgeActions(ref.read(supabaseClientProvider));
});

class NudgeActions {
  NudgeActions(this._supabase);
  final SupabaseClient _supabase;

  Future<void> markAllRead(String memberId) async {
    try {
      await _supabase
          .from('ai_notifications')
          .update({'is_read': true}).eq('target_member_id', memberId);
    } catch (_) {}
  }

  Future<void> markRead(String nudgeId) async {
    try {
      await _supabase
          .from('ai_notifications')
          .update({'is_read': true}).eq('id', nudgeId);
    } catch (_) {}
  }
}

// ── Send Message ──────────────────────────────────────────────────────────────

Future<void> sendAIMessage(WidgetRef ref, String message) async {
  final notifier = ref.read(chatMessagesProvider.notifier);
  notifier.addUserMessage(message);
  ref.read(isAITypingProvider.notifier).state = true;

  // Minimum 1.5s typing feel
  final startTime = DateTime.now();

  try {
    final householdId = ref.read(currentHouseholdIdProvider) ?? '';
    final history = ref.read(chatMessagesProvider);
    // Keep last 10 messages, exclude welcome, serialize
    final trimmed = history
        .where((m) => !m.isWelcome)
        .toList();
    final sliced = trimmed.length > 10
        ? trimmed.sublist(trimmed.length - 10)
        : trimmed;
    final serialized = sliced.map((m) => m.toJson()).toList();

    final response = await ref.read(aiRepositoryProvider).sendMessage(
          message: message,
          history: serialized,
          activeContext: ref.read(activeContextProvider),
          householdId: householdId,
        );

    // Enforce minimum typing delay
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    }

    notifier.addAIMessage(response);
  } catch (_) {
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    }
    notifier.addAIMessage(
        "Sorry, I had trouble connecting 😕 Please try again.");
  } finally {
    ref.read(isAITypingProvider.notifier).state = false;
  }
}
