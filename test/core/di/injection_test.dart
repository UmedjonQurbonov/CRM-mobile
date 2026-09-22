import 'package:crm_mobile/core/di/injection.dart';
import 'package:crm_mobile/core/network/auth_event_bus.dart';
import 'package:crm_mobile/core/network/auth_interceptor.dart';
import 'package:crm_mobile/core/network/dio_client.dart';
import 'package:crm_mobile/core/router/app_router.dart';
import 'package:crm_mobile/core/storage/token_storage.dart';
import 'package:crm_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:crm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crm_mobile/features/products/data/datasources/products_remote_data_source.dart';
import 'package:crm_mobile/features/products/domain/repositories/product_repository.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_bloc.dart';
import 'package:crm_mobile/features/products/presentation/bloc/scanner_cubit.dart';
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
      expect(sl.isRegistered<AuthRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<AuthRepository>(), isTrue);
      expect(sl.isRegistered<AuthBloc>(), isTrue);
      expect(sl.isRegistered<ProductsRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<ProductRepository>(), isTrue);
      expect(sl.isRegistered<ProductsBloc>(), isTrue);
      expect(sl.isRegistered<ScannerCubit>(), isTrue);
      expect(sl.isRegistered<AppRouter>(), isTrue);

      expect(sl<TokenStorage>(), isA<TokenStorage>());
      expect(sl<AuthEventBus>(), isA<AuthEventBus>());
      expect(sl<AuthInterceptor>(), isA<AuthInterceptor>());
      expect(sl<DioClient>(), isA<DioClient>());
      expect(sl<Dio>(), isA<Dio>());
      expect(sl<AuthRemoteDataSource>(), isA<AuthRemoteDataSource>());
      expect(sl<AuthRepository>(), isA<AuthRepository>());
      expect(sl<AuthBloc>(), isA<AuthBloc>());
      expect(sl<ProductsRemoteDataSource>(), isA<ProductsRemoteDataSource>());
      expect(sl<ProductRepository>(), isA<ProductRepository>());
      expect(sl<ProductsBloc>(), isA<ProductsBloc>());
      expect(sl<ScannerCubit>(), isA<ScannerCubit>());
      expect(sl<AppRouter>(), isA<AppRouter>());
    });

    test('resetDependencies cleans up all registrations', () async {
      await initDependencies();
      expect(sl.isRegistered<TokenStorage>(), isTrue);

      await resetDependencies();
      expect(sl.isRegistered<TokenStorage>(), isFalse);
      expect(sl.isRegistered<DioClient>(), isFalse);
      expect(sl.isRegistered<AuthBloc>(), isFalse);
    });
  });
}
