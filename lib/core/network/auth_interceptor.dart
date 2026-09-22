import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';
import 'auth_event_bus.dart';

/// Interceptor that handles access token attachment and automatic
/// 401 Unauthorized silent token refresh via `/api/v1/auth/refresh`.
///
/// Uses [QueuedInterceptor] to serialize requests and prevent race conditions
/// during token refresh.
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage tokenStorage;
  final AuthEventBus authEventBus;
  final Dio _retryClient;

  AuthInterceptor({
    required this.tokenStorage,
    required this.authEventBus,
    Dio? retryClient,
    String? baseUrl,
  })  : _retryClient = retryClient ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
                connectTimeout: ApiEndpoints.connectTimeout,
                receiveTimeout: ApiEndpoints.receiveTimeout,
                sendTimeout: ApiEndpoints.sendTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isPublicEndpoint = path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.refresh);

    if (!isPublicEndpoint) {
      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only intercept 401 Unauthorized responses
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;

    // Do not attempt refresh if 401 was returned on login or refresh endpoints
    if (path.contains(ApiEndpoints.login)) {
      return handler.next(err);
    }

    if (path.contains(ApiEndpoints.refresh)) {
      await tokenStorage.clearTokens();
      authEventBus.emit(AuthEvent.unauthenticated);
      return handler.next(err);
    }

    // Check if token was already refreshed by a previously queued request
    final currentAccessToken = await tokenStorage.getAccessToken();
    final requestAuthHeader =
        err.requestOptions.headers['Authorization'] as String?;

    if (currentAccessToken != null &&
        requestAuthHeader != 'Bearer $currentAccessToken') {
      // Retry immediately with the already refreshed access token
      try {
        err.requestOptions.headers['Authorization'] =
            'Bearer $currentAccessToken';
        final response = await _retryClient.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (retryError) {
        if (retryError is DioException) {
          return handler.next(retryError);
        }
        return handler.reject(err);
      }
    }

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await tokenStorage.clearTokens();
      authEventBus.emit(AuthEvent.unauthenticated);
      return handler.reject(err);
    }

    try {
      final refreshResponse = await _retryClient.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final responseData = refreshResponse.data;
      if (refreshResponse.statusCode == 200 && responseData != null) {
        final tokens = responseData['tokens'] as Map<String, dynamic>?;
        final newAccessToken = tokens?['access_token'] as String?;
        final newRefreshToken = tokens?['refresh_token'] as String?;

        if (newAccessToken != null &&
            newAccessToken.isNotEmpty &&
            newRefreshToken != null &&
            newRefreshToken.isNotEmpty) {
          // Persist updated token pair
          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          authEventBus.emit(AuthEvent.tokenRefreshed);

          // Update header for original request and retry
          err.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';
          final retriedResponse = await _retryClient.fetch(err.requestOptions);
          return handler.resolve(retriedResponse);
        }
      }

      // If tokens payload is invalid or unexpected
      await tokenStorage.clearTokens();
      authEventBus.emit(AuthEvent.unauthenticated);
      return handler.reject(err);
    } catch (_) {
      // Refresh failed (invalid/expired refresh token or network drop)
      await tokenStorage.clearTokens();
      authEventBus.emit(AuthEvent.unauthenticated);
      return handler.reject(err);
    }
  }
}
