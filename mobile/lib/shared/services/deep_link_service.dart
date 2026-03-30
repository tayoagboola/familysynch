import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Listens to incoming deep links and forwards them to GoRouter.
///
/// Call [init] once after the router is available.
/// Handles:
///   familysynch://invite?token=<token>
///   https://familysynch.app/invite?token=<token>
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final _appLinks = AppLinks();

  Future<void> init(GoRouter router) async {
    // Handle link that launched the app from a terminated state.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _navigate(router, initialUri);
      }
    } catch (e) {
      debugPrint('DeepLinkService initial link error: $e');
    }

    // Handle links received while the app is running.
    _appLinks.uriLinkStream.listen(
      (uri) => _navigate(router, uri),
      onError: (e) => debugPrint('DeepLinkService stream error: $e'),
    );
  }

  void _navigate(GoRouter router, Uri uri) {
    // Normalise both custom scheme and https hosts to the same path.
    // familysynch://invite?token=xxx  → /invite?token=xxx
    // https://familysynch.app/invite?token=xxx → /invite?token=xxx
    final path = uri.path.isEmpty ? '/' : uri.path;
    final query = uri.query.isEmpty ? '' : '?${uri.query}';
    router.go('$path$query');
  }
}
