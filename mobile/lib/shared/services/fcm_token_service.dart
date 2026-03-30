import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

/// Registers the FCM token in the household_members table so the backend
/// can target this device for push notifications.
class FcmTokenService {
  FcmTokenService(this._client);

  final SupabaseClient _client;

  Future<void> registerToken() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final token = await NotificationService.instance.getToken();
    if (token == null) return;

    await _client
        .from('household_members')
        .update({'fcm_token': token})
        .eq('user_id', userId);

    // Refresh if FCM rotates the token.
    NotificationService.instance.onTokenRefresh.listen((newToken) async {
      await _client
          .from('household_members')
          .update({'fcm_token': newToken})
          .eq('user_id', userId);
    });
  }
}
