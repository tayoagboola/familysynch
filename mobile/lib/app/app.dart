import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/controllers/auth_notifier.dart';
import '../features/settings/presentation/controllers/settings_providers.dart';
import '../shared/providers/supabase_provider.dart';
import '../shared/services/deep_link_service.dart';
import '../shared/services/fcm_token_service.dart';
import 'router.dart';
import 'theme.dart';

class FamilySyncApp extends ConsumerStatefulWidget {
  const FamilySyncApp({super.key});

  @override
  ConsumerState<FamilySyncApp> createState() => _FamilySyncAppState();
}

class _FamilySyncAppState extends ConsumerState<FamilySyncApp> {
  bool _deepLinkInitialised = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authUser = ref.watch(authUserProvider);

    // Once we have a router instance, start listening for deep links.
    if (!_deepLinkInitialised) {
      _deepLinkInitialised = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DeepLinkService.instance.init(router);
      });
    }

    // Register FCM token whenever a user signs in.
    authUser.whenData((user) {
      if (user != null) {
        FcmTokenService(ref.read(supabaseClientProvider)).registerToken();
      }
    });

    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'FamilySync',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
