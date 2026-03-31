/// ApiClient — base HTTP client for all FastAPI REST calls.
///
/// Responsibilities:
/// - Attach JWT access token to every request header
/// - Auto-refresh JWT on 401 response using refresh token
/// - Retry original request once after refresh
/// - Store/load tokens from flutter_secure_storage
/// - Base URL from environment config
///
/// Usage:
///   final api = ref.read(apiClientProvider);
///   final data = await api.get('/tasks');
///   final data = await api.post('/grocery', body: {...});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:familysynch/core/constants/app_constants.dart';

const _storage = FlutterSecureStorage();
const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  // ── Token Storage ──────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // ── Request Methods ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post(path, data: body);
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.put(path, data: body);
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.delete(path, data: body);
    return _unwrap(response);
  }

  // ── Interceptors ───────────────────────────────────────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = await getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final retryResponse = await _dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
        return;
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await Dio().post(
        '${AppConstants.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newToken = response.data['data']['access_token'] as String;
      await _storage.write(key: _accessTokenKey, value: newToken);
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }

  Map<String, dynamic> _unwrap(Response response) {
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == false) {
      throw ApiException(data['error'] ?? 'Unknown error');
    }
    return data['data'] as Map<String, dynamic>;
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
