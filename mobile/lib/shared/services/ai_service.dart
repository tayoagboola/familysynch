/// AIService — FamilyAI chat and nudge management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(ref.read(apiClientProvider));
});

class AIService {
  final ApiClient _api;
  AIService(this._api);

  Future<Map<String, dynamic>> chat({
    required String message,
    required List<Map<String, String>> history,
    List<String> activeContext = const ['calendar', 'tasks', 'grocery'],
  }) =>
      _api.post('/ai/chat', body: {
        'message': message,
        'history': history,
        'active_context': activeContext,
      });

  Future<Map<String, dynamic>> getNudges() => _api.get('/ai/nudges');

  Future<void> markNudgesRead(List<String> nudgeIds) =>
      _api.post('/ai/nudges/read', body: {'nudge_ids': nudgeIds});
}
