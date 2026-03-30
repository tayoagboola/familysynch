import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/supabase_provider.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../calendar/presentation/controllers/calendar_providers.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/controllers/task_providers.dart';

// ── KidXP Model ───────────────────────────────────────────────────────────────

class KidXP {
  const KidXP({
    required this.totalPoints,
    required this.currentLevel,
    required this.xpInCurrentLevel,
    required this.xpNeededForNextLevel,
    required this.streakDays,
  });

  final int totalPoints;
  final int currentLevel;
  final int xpInCurrentLevel;
  final int xpNeededForNextLevel;
  final int streakDays;

  double get levelProgress =>
      xpNeededForNextLevel == 0
          ? 1.0
          : (xpInCurrentLevel / xpNeededForNextLevel).clamp(0.0, 1.0);

  String get levelName => switch (currentLevel) {
        1 => 'Starter',
        2 => 'Helper',
        3 => 'Champion',
        4 => 'Explorer',
        5 => 'Superstar',
        _ => 'Legend',
      };

  String get starsForLevel {
    final count = currentLevel.clamp(1, 5);
    return '⭐' * count;
  }

  factory KidXP.fromJson(Map<String, dynamic> json) => KidXP(
        totalPoints: (json['total_points'] as int?) ?? 0,
        currentLevel: (json['current_level'] as int?) ?? 1,
        xpInCurrentLevel: (json['xp_in_current_level'] as int?) ?? 0,
        xpNeededForNextLevel: (json['xp_needed_for_next_level'] as int?) ?? 100,
        streakDays: (json['streak_days'] as int?) ?? 0,
      );

  static KidXP initial() => const KidXP(
        totalPoints: 0,
        currentLevel: 1,
        xpInCurrentLevel: 0,
        xpNeededForNextLevel: 100,
        streakDays: 0,
      );
}

// ── Badge Model ───────────────────────────────────────────────────────────────

class KidBadge {
  const KidBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.gradientColor1,
    required this.gradientColor2,
    required this.isEarned,
    this.earnedAt,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color gradientColor1;
  final Color gradientColor2;
  final bool isEarned;
  final DateTime? earnedAt;

  factory KidBadge.fromJson(Map<String, dynamic> json,
      {required bool isEarned, DateTime? earnedAt}) {
    Color parseHex(String? hex, Color fallback) {
      if (hex == null || hex.isEmpty) return fallback;
      final cleaned = hex.replaceAll('#', '');
      return Color(int.tryParse('FF$cleaned', radix: 16) ?? fallback.toARGB32());
    }

    return KidBadge(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🏅',
      gradientColor1:
          parseHex(json['gradient_color_1'] as String?, const Color(0xFFFF6B35)),
      gradientColor2:
          parseHex(json['gradient_color_2'] as String?, const Color(0xFFFFD166)),
      isEarned: isEarned,
      earnedAt: earnedAt,
    );
  }
}

// ── Kid Tasks Provider ────────────────────────────────────────────────────────

// Filters global tasks stream to only this kid's tasks
final kidTasksProvider =
    Provider.family<List<Task>, String>((ref, kidId) {
  final all = ref.watch(tasksProvider).valueOrNull ?? [];
  return all.where((t) => t.assignedTo == kidId).toList()
    ..sort((a, b) {
      // Incomplete first
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      return 0;
    });
});

// ── Kid Today Events ──────────────────────────────────────────────────────────

final kidTodayEventsProvider =
    Provider.family<List<CalendarEvent>, String>((ref, kidId) {
  final all = ref.watch(calendarEventsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return all.where((e) {
    final start = e.startTime;
    final isToday = !start.isBefore(today) && start.isBefore(tomorrow);
    final isAssigned = e.assignedTo == null || e.assignedTo == kidId;
    return isToday && isAssigned;
  }).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});

// ── Kid XP Provider ───────────────────────────────────────────────────────────

final kidXPProvider =
    StreamProvider.family<KidXP, String>((ref, kidId) {
  final supabase = ref.read(supabaseClientProvider);
  return supabase
      .from('kid_progress')
      .stream(primaryKey: ['id'])
      .eq('member_id', kidId)
      .map((rows) =>
          rows.isNotEmpty ? KidXP.fromJson(rows.first) : KidXP.initial());
});

// ── Kid Badges Provider ───────────────────────────────────────────────────────

final kidBadgesProvider =
    FutureProvider.family<List<KidBadge>, String>((ref, kidId) async {
  final supabase = ref.read(supabaseClientProvider);

  final earned = await supabase
      .from('kid_badges')
      .select('badge_id, earned_at')
      .eq('member_id', kidId);

  final all = await supabase.from('badge_definitions').select();

  final earnedMap = <String, DateTime>{};
  for (final e in earned as List) {
    earnedMap[e['badge_id'] as String] =
        DateTime.parse(e['earned_at'] as String);
  }

  return (all as List).map((b) {
    final badgeId = b['id'] as String;
    return KidBadge.fromJson(
      b,
      isEarned: earnedMap.containsKey(badgeId),
      earnedAt: earnedMap[badgeId],
    );
  }).toList()
    ..sort((a, b) {
      if (a.isEarned != b.isEarned) return a.isEarned ? -1 : 1;
      return 0;
    });
});

// ── Kid Task Actions ──────────────────────────────────────────────────────────

final kidTaskActionsProvider = Provider<KidTaskActions>((ref) {
  return KidTaskActions(ref);
});

class KidTaskActions {
  KidTaskActions(this._ref);
  final Ref _ref;

  Future<bool> completeTask(String taskId, bool newValue) async {
    final supabase = _ref.read(supabaseClientProvider);
    try {
      await supabase.from('tasks').update({
        'completed': newValue,
        'completed_at':
            newValue ? DateTime.now().toIso8601String() : null,
        'completed_by': newValue
            ? supabase.auth.currentUser?.id
            : null,
      }).eq('id', taskId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
