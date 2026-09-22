import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../constants/api_endpoints.dart';
import '../network/auth_event_bus.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../router/app_router.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

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

  // 4. Feature: Auth
  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        tokenStorage: sl<TokenStorage>(),
      ),
    );
  }

  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        authRepository: sl<AuthRepository>(),
        authEventBus: sl<AuthEventBus>(),
      ),
    );
  }

  // 5. Navigation & Router
  if (!sl.isRegistered<AppRouter>()) {
    sl.registerLazySingleton<AppRouter>(
      () => AppRouter(authBloc: sl<AuthBloc>()),
    );
  }
}

/// Resets all registered dependencies (primarily for isolation in tests).
Future<void> resetDependencies() async {
  await sl.reset();
}
