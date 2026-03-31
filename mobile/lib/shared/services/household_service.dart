/// HouseholdService — household creation, joining, and member management.
///
/// CRITICAL: After create() or join(), save the new tokens immediately.
/// The new tokens contain household_id — required for all subsequent calls.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';

final householdServiceProvider = Provider<HouseholdService>((ref) {
  return HouseholdService(ref.read(apiClientProvider));
});

class HouseholdService {
  final ApiClient _api;
  HouseholdService(this._api);

  Future<Map<String, dynamic>> createHousehold(String name) async {
    final data = await _api.post('/household/create', body: {'name': name});
    // Save new tokens — now contain household_id
    await _api.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<Map<String, dynamic>> joinHousehold(String inviteCode) async {
    final data = await _api.post('/household/join',
        body: {'invite_code': inviteCode});
    await _api.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<Map<String, dynamic>> getMyHousehold() => _api.get('/household/me');

  Future<List<dynamic>> getMembers() async {
    final data = await _api.get('/household/members');
    return data as List<dynamic>;
  }

  Future<void> updateHousehold(String name) =>
      _api.put('/household/me', body: {'name': name});

  Future<void> updateMemberRole(String memberId, String role) =>
      _api.put('/household/members/$memberId/role', body: {'role': role});

  Future<void> removeMember(String memberId) =>
      _api.delete('/household/members/$memberId');

  Future<Map<String, dynamic>> regenerateInvite() =>
      _api.post('/household/invite');
}
