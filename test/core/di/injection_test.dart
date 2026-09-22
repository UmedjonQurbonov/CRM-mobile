import 'package:crm_mobile/core/di/injection.dart';
import 'package:crm_mobile/core/network/auth_event_bus.dart';
import 'package:crm_mobile/core/network/auth_interceptor.dart';
import 'package:crm_mobile/core/network/dio_client.dart';
import 'package:crm_mobile/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await resetDependencies();
  });

  tearDown(() async {
    await resetDependencies();
  });

  group('Dependency Injection', () {
    test('initDependencies registers all core singletons in get_it', () async {
      await initDependencies();

      expect(sl.isRegistered<FlutterSecureStorage>(), isTrue);
      expect(sl.isRegistered<TokenStorage>(), isTrue);
      expect(sl.isRegistered<AuthEventBus>(), isTrue);
      expect(sl.isRegistered<AuthInterceptor>(), isTrue);
      expect(sl.isRegistered<DioClient>(), isTrue);
      expect(sl.isRegistered<Dio>(), isTrue);

      expect(sl<TokenStorage>(), isA<TokenStorage>());
      expect(sl<AuthEventBus>(), isA<AuthEventBus>());
      expect(sl<AuthInterceptor>(), isA<AuthInterceptor>());
      expect(sl<DioClient>(), isA<DioClient>());
      expect(sl<Dio>(), isA<Dio>());
    });

    test('resetDependencies cleans up all registrations', () async {
      await initDependencies();
      expect(sl.isRegistered<TokenStorage>(), isTrue);

      await resetDependencies();
      expect(sl.isRegistered<TokenStorage>(), isFalse);
      expect(sl.isRegistered<DioClient>(), isFalse);
    });
  });
}
