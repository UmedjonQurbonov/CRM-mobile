import 'package:crm_mobile/core/constants/api_endpoints.dart';
import 'package:crm_mobile/core/network/auth_event_bus.dart';
import 'package:crm_mobile/core/network/auth_interceptor.dart';
import 'package:crm_mobile/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class MockAuthEventBus extends Mock implements AuthEventBus {}

class MockDio extends Mock implements Dio {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeDioException extends Fake implements DioException {}

class FakeResponse<T> extends Fake implements Response<T> {}

void main() {
  late MockTokenStorage mockTokenStorage;
  late MockAuthEventBus mockAuthEventBus;
  late MockDio mockRetryClient;
  late AuthInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeDioException());
    registerFallbackValue(FakeResponse<dynamic>());
    registerFallbackValue(AuthEvent.unauthenticated);
  });

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    mockAuthEventBus = MockAuthEventBus();
    mockRetryClient = MockDio();

    interceptor = AuthInterceptor(
      tokenStorage: mockTokenStorage,
      authEventBus: mockAuthEventBus,
      retryClient: mockRetryClient,
    );
  });

  group('AuthInterceptor - onRequest', () {
    test('attaches Authorization header for protected endpoints', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'valid_access_token');

      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: ApiEndpoints.products);

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer valid_access_token');
      verify(() => handler.next(options)).called(1);
    });

    test('does NOT attach Authorization header for /login endpoint', () async {
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: ApiEndpoints.login);

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verifyNever(() => mockTokenStorage.getAccessToken());
      verify(() => handler.next(options)).called(1);
    });

    test('does NOT attach Authorization header for /refresh endpoint', () async {
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: ApiEndpoints.refresh);

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verifyNever(() => mockTokenStorage.getAccessToken());
      verify(() => handler.next(options)).called(1);
    });
  });

  group('AuthInterceptor - onError 401 handling', () {
    test('successfully refreshes token and retries original request', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: ApiEndpoints.products,
        headers: {'Authorization': 'Bearer expired_token'},
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'expired_token');
      when(() => mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => 'valid_refresh_token');
      when(
        () => mockTokenStorage.saveTokens(
          accessToken: 'new_access_token',
          refreshToken: 'new_refresh_token',
        ),
      ).thenAnswer((_) async {});

      // Mock refresh endpoint response
      final refreshResponse = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.refresh),
        statusCode: 200,
        data: {
          'tokens': {
            'access_token': 'new_access_token',
            'refresh_token': 'new_refresh_token',
            'token_type': 'Bearer',
            'expires_in': 3600,
          },
        },
      );

      when(
        () => mockRetryClient.post<Map<String, dynamic>>(
          ApiEndpoints.refresh,
          data: {'refresh_token': 'valid_refresh_token'},
        ),
      ).thenAnswer((_) async => refreshResponse);

      // Mock retry response
      final retrySuccessResponse = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {'items': []},
      );

      when(() => mockRetryClient.fetch(requestOptions))
          .thenAnswer((_) async => retrySuccessResponse);

      await interceptor.onError(dioException, handler);

      verify(
        () => mockTokenStorage.saveTokens(
          accessToken: 'new_access_token',
          refreshToken: 'new_refresh_token',
        ),
      ).called(1);
      verify(() => mockAuthEventBus.emit(AuthEvent.tokenRefreshed)).called(1);
      expect(requestOptions.headers['Authorization'], 'Bearer new_access_token');
      verify(() => handler.resolve(retrySuccessResponse)).called(1);
    });

    test('clears storage, emits unauthenticated and rejects on refresh failure', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: ApiEndpoints.orders,
        headers: {'Authorization': 'Bearer expired_token'},
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'expired_token');
      when(() => mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => 'revoked_refresh_token');
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      // Mock refresh endpoint returning 401
      when(
        () => mockRetryClient.post<Map<String, dynamic>>(
          ApiEndpoints.refresh,
          data: {'refresh_token': 'revoked_refresh_token'},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.refresh),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.refresh),
            statusCode: 401,
          ),
        ),
      );

      await interceptor.onError(dioException, handler);

      verify(() => mockTokenStorage.clearTokens()).called(1);
      verify(() => mockAuthEventBus.emit(AuthEvent.unauthenticated)).called(1);
      verify(() => handler.reject(dioException)).called(1);
    });

    test('clears storage, emits unauthenticated and rejects when refresh token is missing', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: ApiEndpoints.expenses,
        headers: {'Authorization': 'Bearer expired_token'},
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'expired_token');
      when(() => mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await interceptor.onError(dioException, handler);

      verify(() => mockTokenStorage.clearTokens()).called(1);
      verify(() => mockAuthEventBus.emit(AuthEvent.unauthenticated)).called(1);
      verify(() => handler.reject(dioException)).called(1);
      verifyNever(
        () => mockRetryClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      );
    });

    test('does not refresh when 401 occurs on login endpoint', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(path: ApiEndpoints.login);
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      await interceptor.onError(dioException, handler);

      verifyNever(() => mockTokenStorage.getRefreshToken());
      verifyNever(() => mockTokenStorage.clearTokens());
      verify(() => handler.next(dioException)).called(1);
    });

    test('clears tokens and emits unauthenticated when 401 occurs on refresh endpoint', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(path: ApiEndpoints.refresh);
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await interceptor.onError(dioException, handler);

      verify(() => mockTokenStorage.clearTokens()).called(1);
      verify(() => mockAuthEventBus.emit(AuthEvent.unauthenticated)).called(1);
      verify(() => handler.next(dioException)).called(1);
    });

    test('passes non-401 errors through without attempting refresh', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(path: ApiEndpoints.products);
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 500,
        ),
      );

      await interceptor.onError(dioException, handler);

      verifyNever(() => mockTokenStorage.getRefreshToken());
      verify(() => handler.next(dioException)).called(1);
    });
  });
}
