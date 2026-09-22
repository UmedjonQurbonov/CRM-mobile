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
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/pos_checkout/presentation/bloc/cart_bloc.dart';
import '../../features/pos_checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/products_bloc.dart';
import '../../features/products/presentation/bloc/scanner_cubit.dart';

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

  // 5. Feature: Products & QR Scanner
  if (!sl.isRegistered<ProductsRemoteDataSource>()) {
    sl.registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(client: sl<DioClient>()),
    );
  }

  if (!sl.isRegistered<ProductRepository>()) {
    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        remoteDataSource: sl<ProductsRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<ProductsBloc>()) {
    sl.registerFactory<ProductsBloc>(
      () => ProductsBloc(productRepository: sl<ProductRepository>()),
    );
  }

  if (!sl.isRegistered<ScannerCubit>()) {
    sl.registerFactory<ScannerCubit>(
      () => ScannerCubit(productRepository: sl<ProductRepository>()),
    );
  }

  // 6. Feature: Orders & POS Checkout
  if (!sl.isRegistered<OrdersRemoteDataSource>()) {
    sl.registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(client: sl<DioClient>()),
    );
  }

  if (!sl.isRegistered<OrdersRepository>()) {
    sl.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(
        remoteDataSource: sl<OrdersRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<CartBloc>()) {
    sl.registerLazySingleton<CartBloc>(() => CartBloc());
  }

  if (!sl.isRegistered<CheckoutBloc>()) {
    sl.registerFactory<CheckoutBloc>(
      () => CheckoutBloc(ordersRepository: sl<OrdersRepository>()),
    );
  }

  if (!sl.isRegistered<OrdersBloc>()) {
    sl.registerFactory<OrdersBloc>(
      () => OrdersBloc(ordersRepository: sl<OrdersRepository>()),
    );
  }

  // 7. Navigation & Router
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
