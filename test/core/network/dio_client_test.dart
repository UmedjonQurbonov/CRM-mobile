import 'package:crm_mobile/core/constants/api_endpoints.dart';
import 'package:crm_mobile/core/network/auth_interceptor.dart';
import 'package:crm_mobile/core/network/dio_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthInterceptor extends Mock implements AuthInterceptor {}

void main() {
  late MockAuthInterceptor mockAuthInterceptor;

  setUp(() {
    mockAuthInterceptor = MockAuthInterceptor();
  });

  group('DioClient', () {
    test('initializes with default Android base URL and 15s timeouts', () {
      final client = DioClient(authInterceptor: mockAuthInterceptor);

      expect(client.dio.options.baseUrl, ApiEndpoints.defaultAndroidBaseUrl);
      expect(client.dio.options.connectTimeout, const Duration(seconds: 15));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 15));
      expect(client.dio.options.sendTimeout, const Duration(seconds: 15));
      expect(client.dio.options.headers['Content-Type'], 'application/json');
      expect(client.dio.options.headers['Accept'], 'application/json');
      expect(client.dio.interceptors, contains(mockAuthInterceptor));
    });

    test('supports overriding base URL with localhost or custom URL', () {
      final client = DioClient(
        baseUrl: ApiEndpoints.defaultLocalhostBaseUrl,
        authInterceptor: mockAuthInterceptor,
      );

      expect(client.dio.options.baseUrl, ApiEndpoints.defaultLocalhostBaseUrl);
    });
  });
}
