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
import '../../features/expenses/data/datasources/expenses_remote_data_source.dart';
import '../../features/expenses/data/repositories/expenses_repository_impl.dart';
import '../../features/expenses/domain/repositories/expenses_repository.dart';
import '../../features/expenses/presentation/bloc/expenses_bloc.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/products_bloc.dart';
import '../../features/products/presentation/bloc/scanner_cubit.dart';
import '../../features/sellers/data/datasources/sellers_remote_data_source.dart';
import '../../features/sellers/data/repositories/sellers_repository_impl.dart';
import '../../features/sellers/domain/repositories/sellers_repository.dart';
import '../../features/sellers/presentation/bloc/sellers_bloc.dart';
import '../../features/analytics/data/datasources/analytics_remote_data_source.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/analytics/presentation/bloc/my_earnings_bloc.dart';

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

  // 7. Feature: Expenses (Owner only)
  if (!sl.isRegistered<ExpensesRemoteDataSource>()) {
    sl.registerLazySingleton<ExpensesRemoteDataSource>(
      () => ExpensesRemoteDataSourceImpl(client: sl<DioClient>()),
    );
  }

  if (!sl.isRegistered<ExpensesRepository>()) {
    sl.registerLazySingleton<ExpensesRepository>(
      () => ExpensesRepositoryImpl(
        remoteDataSource: sl<ExpensesRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<ExpensesBloc>()) {
    sl.registerFactory<ExpensesBloc>(
      () => ExpensesBloc(expensesRepository: sl<ExpensesRepository>()),
    );
  }

  // 8. Feature: Sellers (Owner only)
  if (!sl.isRegistered<SellersRemoteDataSource>()) {
    sl.registerLazySingleton<SellersRemoteDataSource>(
      () => SellersRemoteDataSourceImpl(client: sl<DioClient>()),
    );
  }

  if (!sl.isRegistered<SellersRepository>()) {
    sl.registerLazySingleton<SellersRepository>(
      () => SellersRepositoryImpl(
        remoteDataSource: sl<SellersRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<SellersBloc>()) {
    sl.registerFactory<SellersBloc>(
      () => SellersBloc(sellersRepository: sl<SellersRepository>()),
    );
  }

  // 9. Feature: Analytics & Earnings
  if (!sl.isRegistered<AnalyticsRemoteDataSource>()) {
    sl.registerLazySingleton<AnalyticsRemoteDataSource>(
      () => AnalyticsRemoteDataSourceImpl(client: sl<DioClient>()),
    );
  }

  if (!sl.isRegistered<AnalyticsRepository>()) {
    sl.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(
        remoteDataSource: sl<AnalyticsRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<AnalyticsBloc>()) {
    sl.registerFactory<AnalyticsBloc>(
      () => AnalyticsBloc(analyticsRepository: sl<AnalyticsRepository>()),
    );
  }

  if (!sl.isRegistered<MyEarningsBloc>()) {
    sl.registerFactory<MyEarningsBloc>(
      () => MyEarningsBloc(analyticsRepository: sl<AnalyticsRepository>()),
    );
  }

  // 10. Navigation & Router
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
