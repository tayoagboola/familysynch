import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/household.dart';
import '../models/household_model.dart';
import '../models/household_member_model.dart';

class HouseholdRepository {
  HouseholdRepository(this._client);

  final SupabaseClient _client;

  Future<Household?> getCurrentHousehold() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _client
        .from('household_members')
        .select('households(*)')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    final raw = data['households'] as Map<String, dynamic>?;
    if (raw == null) return null;
    return HouseholdModel.fromJson(raw).toDomain();
  }

  Future<Household> createHousehold({
    required String name,
    String? avatarEmoji,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final displayName =
        _client.auth.currentUser!.userMetadata?['full_name'] as String? ??
            'Me';

    final data = await _client
        .from('households')
        .insert({'name': name, 'created_by': userId})
        .select()
        .single();

    final household = HouseholdModel.fromJson(data).toDomain();

    await _client.from('household_members').insert({
      'household_id': household.id,
      'user_id': userId,
      'display_name': displayName,
      'color': '#2196F3',
      'role': 'adult',
    });

    return household;
  }

  Future<String> generateInviteLink(String householdId) async {
    final data = await _client
        .from('household_invites')
        .insert({
          'household_id': householdId,
          'created_by': _client.auth.currentUser!.id,
        })
        .select('token')
        .single();

    final token = data['token'] as String;
    return 'familysync://invite?token=$token';
  }

  Future<void> acceptInvite(String token) async {
    final userId = _client.auth.currentUser!.id;
    final displayName =
        _client.auth.currentUser!.userMetadata?['full_name'] as String? ??
            'New Member';

    // Load invite
    final invite = await _client
        .from('household_invites')
        .select()
        .eq('token', token)
        .maybeSingle();

    if (invite == null) throw Exception('Invalid invite link.');
    if (invite['used_at'] != null) throw Exception('This link has already been used.');
    final expires = DateTime.parse(invite['expires_at'] as String);
    if (expires.isBefore(DateTime.now())) throw Exception('This invite has expired.');

    final householdId = invite['household_id'] as String;

    // Determine color (next available from list)
    final members = await _client
        .from('household_members')
        .select('color')
        .eq('household_id', householdId);
    final usedColors = (members as List).map((m) => m['color'] as String).toSet();
    const colors = ['#2196F3','#E91E63','#4CAF50','#FF9800','#9C27B0','#FF5722'];
    final color = colors.firstWhere((c) => !usedColors.contains(c), orElse: () => colors.first);

    await _client.from('household_members').insert({
      'household_id': householdId,
      'user_id': userId,
      'display_name': displayName,
      'color': color,
      'role': 'adult',
    });

    await _client.from('household_invites').update({
      'used_by': userId,
      'used_at': DateTime.now().toIso8601String(),
    }).eq('token', token);
  }

  Future<String?> getCurrentMemberRole() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _client
        .from('household_members')
        .select('role')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();
    return data?['role'] as String?;
  }
}
