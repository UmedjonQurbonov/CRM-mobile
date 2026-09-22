import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../constants/api_endpoints.dart';
import '../network/auth_event_bus.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final GetIt sl = GetIt.instance;

/// Configures and registers all core service locator dependencies.
Future<void> initDependencies({String? baseUrl}) async {
  if (baseUrl != null && baseUrl.isNotEmpty) {
    ApiEndpoints.baseUrl = baseUrl;
  }

  // 1. Storage & Security
  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      ),
    );
  }

  if (!sl.isRegistered<TokenStorage>()) {
    sl.registerLazySingleton<TokenStorage>(
      () => TokenStorage(secureStorage: sl<FlutterSecureStorage>()),
    );
  }

  // 2. Authentication Event Bus
  if (!sl.isRegistered<AuthEventBus>()) {
    sl.registerLazySingleton<AuthEventBus>(() => AuthEventBus());
  }

  // 3. Network: AuthInterceptor & DioClient
  if (!sl.isRegistered<AuthInterceptor>()) {
    sl.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(
        tokenStorage: sl<TokenStorage>(),
        authEventBus: sl<AuthEventBus>(),
        baseUrl: ApiEndpoints.baseUrl,
      ),
    );
  }

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(
        baseUrl: ApiEndpoints.baseUrl,
        authInterceptor: sl<AuthInterceptor>(),
      ),
    );
  }

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  }
}

/// Resets all registered dependencies (primarily for isolation in tests).
Future<void> resetDependencies() async {
  await sl.reset();
}
