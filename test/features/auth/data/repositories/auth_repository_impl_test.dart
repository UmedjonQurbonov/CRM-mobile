import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/core/storage/token_storage.dart';
import 'package:crm_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:crm_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:crm_mobile/features/auth/data/models/user_model.dart';
import 'package:crm_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockTokenStorage mockTokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      tokenStorage: mockTokenStorage,
    );
  });

  final testUser = UserModel(
    id: 'user-1',
    name: 'Admin',
    phone: '+992900000000',
    role: 'owner',
    commissionRate: Decimal.zero,
  );

  const testTokens = TokenPairModel(
    accessToken: 'access_123',
    refreshToken: 'refresh_456',
    tokenType: 'Bearer',
    expiresIn: 3600,
  );

  final testAuthResponse = AuthResponseModel(
    tokens: testTokens,
    user: testUser,
  );

  group('AuthRepositoryImpl - login', () {
    test('successfully logs in, saves tokens and profile, and returns UserEntity', () async {
      when(() => mockTokenStorage.getOrCreateDeviceId())
          .thenAnswer((_) async => 'device-uuid');
      when(
        () => mockRemoteDataSource.login(
          phone: '+992900000000',
          password: 'Password123!',
          deviceId: 'device-uuid',
        ),
      ).thenAnswer((_) async => testAuthResponse);

      when(
        () => mockTokenStorage.saveTokens(
          accessToken: 'access_123',
          refreshToken: 'refresh_456',
        ),
      ).thenAnswer((_) async {});

      when(
        () => mockTokenStorage.saveUserProfile(any()),
      ).thenAnswer((_) async {});

      final result = await repository.login(
        phone: '+992900000000',
        password: 'Password123!',
      );

      expect(result.id, 'user-1');
      expect(result.isOwner, isTrue);

      verify(
        () => mockTokenStorage.saveTokens(
          accessToken: 'access_123',
          refreshToken: 'refresh_456',
        ),
      ).called(1);
      verify(() => mockTokenStorage.saveUserProfile(any())).called(1);
    });

    test('rethrows mapped Failure on DioException', () async {
      when(() => mockTokenStorage.getOrCreateDeviceId())
          .thenAnswer((_) async => 'device-uuid');
      when(
        () => mockRemoteDataSource.login(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
            statusCode: 401,
            data: {
              'code': 'INVALID_CREDENTIALS',
              'message': 'Invalid phone or password',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.login(
          phone: '+992900000000',
          password: 'WrongPassword',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.code,
            'code',
            'INVALID_CREDENTIALS',
          ),
        ),
      );
    });
  });

  group('AuthRepositoryImpl - logout', () {
    test('calls remote logout and always clears local tokens', () async {
      when(() => mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => 'refresh_456');
      when(() => mockRemoteDataSource.logout(refreshToken: 'refresh_456'))
          .thenAnswer((_) async {});
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockRemoteDataSource.logout(refreshToken: 'refresh_456'))
          .called(1);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });

    test('clears local tokens even if remote logout fails', () async {
      when(() => mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => 'refresh_456');
      when(() => mockRemoteDataSource.logout(refreshToken: 'refresh_456'))
          .thenThrow(Exception('Network failure'));
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockTokenStorage.clearTokens()).called(1);
    });
  });

  group('AuthRepositoryImpl - checkAuthStatus', () {
    test('returns null and clears tokens when tokens are absent', () async {
      when(() => mockTokenStorage.getAccessToken()).thenAnswer((_) async => null);
      when(() => mockTokenStorage.getRefreshToken()).thenAnswer((_) async => null);
      when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});

      final result = await repository.checkAuthStatus();

      expect(result, isNull);
      verify(() => mockTokenStorage.clearTokens()).called(1);
    });

    test('returns UserEntity when tokens and cached profile exist', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'access_123');
      when(() => mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => 'refresh_456');
      when(() => mockTokenStorage.getUserProfile()).thenAnswer(
        (_) async =>
            '{"id":"user-1","name":"Admin","phone":"+992900000000","role":"owner","commission_rate":"0.00"}',
      );

      final result = await repository.checkAuthStatus();

      expect(result, isNotNull);
      expect(result?.name, 'Admin');
      expect(result?.isOwner, isTrue);
    });
  });
}
