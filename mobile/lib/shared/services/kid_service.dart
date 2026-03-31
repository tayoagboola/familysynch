/// KidService — XP progress and badges for Kid Mode screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';

final kidServiceProvider = Provider<KidService>((ref) {
  return KidService(ref.read(apiClientProvider));
});

class KidService {
  final ApiClient _api;
  KidService(this._api);

  Future<Map<String, dynamic>> getProgress(String memberId) =>
      _api.get('/kid/$memberId/progress');

  Future<Map<String, dynamic>> getBadges(String memberId) =>
      _api.get('/kid/$memberId/badges');
}
