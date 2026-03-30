import 'package:supabase_flutter/supabase_flutter.dart';

class AIRepository {
  AIRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<String> sendMessage({
    required String message,
    required List<Map<String, dynamic>> history,
    required Set<String> activeContext,
    required String householdId,
  }) async {
    final response = await _supabase.functions.invoke(
      'family-ai',
      body: {
        'message': message,
        'history': history,
        'activeContext': activeContext.toList(),
        'householdId': householdId,
        'userId': _supabase.auth.currentUser?.id ?? '',
      },
    );

    if (response.status != 200) {
      throw Exception('AI request failed: ${response.status}');
    }

    final data = response.data as Map<String, dynamic>?;
    return (data?['response'] as String?) ??
        "I couldn't process that. Please try again.";
  }
}
