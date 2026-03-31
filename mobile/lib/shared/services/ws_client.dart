/// WsClient — base WebSocket client for real-time streams.
///
/// Responsibilities:
/// - Connect to FastAPI WebSocket endpoints with JWT auth
/// - Reconnect automatically on disconnect (exponential backoff)
/// - Send periodic pings to keep connection alive
/// - Parse incoming JSON events and broadcast as Dart streams
/// - Disconnect cleanly on logout
///
/// Usage:
///   final ws = ref.read(wsClientProvider);
///   ws.connect('/ws/grocery').listen((event) {
///     // event = {'event': 'grocery:item_added', 'data': {...}}
///   });

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:familysynch/core/constants/app_constants.dart';
import 'package:familysynch/shared/services/api_client.dart';

final wsClientProvider = Provider<WsClient>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return WsClient(apiClient);
});

class WsClient {
  final ApiClient _apiClient;
  final Map<String, WebSocket> _sockets = {};
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};
  final Map<String, Timer> _pingTimers = {};
  final Map<String, int> _retryDelays = {};

  WsClient(this._apiClient);

  // ── Connect ───────────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> connect(String path) {
    if (_controllers.containsKey(path)) {
      return _controllers[path]!.stream;
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers[path] = controller;
    _retryDelays[path] = 1;
    _connectSocket(path, controller);
    return controller.stream;
  }

  Future<void> _connectSocket(
    String path,
    StreamController<Map<String, dynamic>> controller,
  ) async {
    final token = await _apiClient.getAccessToken();
    if (token == null) return;

    final wsUrl = AppConstants.wsBaseUrl;
    final uri = Uri.parse('$wsUrl$path?token=$token');

    try {
      final socket = await WebSocket.connect(uri.toString());
      _sockets[path] = socket;
      _retryDelays[path] = 1; // reset on successful connect

      // Start ping timer (every 25 seconds)
      _pingTimers[path]?.cancel();
      _pingTimers[path] = Timer.periodic(
        const Duration(seconds: 25),
        (_) => socket.add('ping'),
      );

      socket.listen(
        (raw) {
          if (raw == 'pong') return;
          try {
            final parsed = jsonDecode(raw as String) as Map<String, dynamic>;
            if (!controller.isClosed) controller.add(parsed);
          } catch (_) {}
        },
        onDone: () => _onDisconnect(path, controller),
        onError: (_) => _onDisconnect(path, controller),
        cancelOnError: false,
      );
    } catch (_) {
      _onDisconnect(path, controller);
    }
  }

  void _onDisconnect(
    String path,
    StreamController<Map<String, dynamic>> controller,
  ) {
    _pingTimers[path]?.cancel();
    _sockets.remove(path);

    if (controller.isClosed) return;

    // Exponential backoff reconnect
    final delay = _retryDelays[path] ?? 1;
    _retryDelays[path] = (delay * 2).clamp(1, 30);

    Future.delayed(Duration(seconds: delay), () {
      if (!controller.isClosed) {
        _connectSocket(path, controller);
      }
    });
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> disconnect(String path) async {
    _pingTimers[path]?.cancel();
    _pingTimers.remove(path);
    await _sockets[path]?.close();
    _sockets.remove(path);
    await _controllers[path]?.close();
    _controllers.remove(path);
    _retryDelays.remove(path);
  }

  Future<void> disconnectAll() async {
    for (final path in List.from(_controllers.keys)) {
      await disconnect(path);
    }
  }
}
