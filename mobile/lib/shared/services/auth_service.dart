/// AuthService — handles all authentication flows.
///
/// Endpoints:
///   POST /auth/register
///   POST /auth/login
///   POST /auth/google
///   POST /auth/apple
///   POST /auth/refresh
///   POST /auth/logout
///   GET  /auth/me

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/shared/services/api_client.dart';
import 'package:familysynch/shared/services/ws_client.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider), ref.read(wsClientProvider));
});

class AuthService {
  final ApiClient _api;
  final WsClient _ws;

  AuthService(this._api, this._ws);

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/register', body: {
      'full_name': fullName,
      'email': email,
      'password': password,
    });
    await _api.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    await _api.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<Map<String, dynamic>> googleAuth(String idToken) async {
    final data = await _api.post('/auth/google', body: {'id_token': idToken});
    await _api.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<Map<String, dynamic>> appleAuth({
    required String identityToken,
    String? fullName,
  }) async {
    final data = await _api.post('/auth/apple', body: {
      'identity_token': identityToken,
      if (fullName != null) 'full_name': fullName,
    });
    await _api.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<Map<String, dynamic>> getMe() => _api.get('/auth/me');

  Future<void> logout(String fcmToken) async {
    try {
      await _api.delete('/notifications/register',
          body: {'fcm_token': fcmToken, 'device_platform': 'android'});
    } catch (_) {}
    await _api.post('/auth/logout');
    await _api.clearTokens();
    await _ws.disconnectAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.getAccessToken();
    return token != null;
  }
}
