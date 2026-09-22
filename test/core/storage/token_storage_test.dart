import 'package:crm_mobile/core/constants/storage_keys.dart';
import 'package:crm_mobile/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    tokenStorage = TokenStorage(secureStorage: mockSecureStorage);
  });

  group('TokenStorage', () {
    const testAccessToken = 'access_token_123';
    const testRefreshToken = 'refresh_token_456';

    test('saveTokens persists both access and refresh tokens', () async {
      when(
        () => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await tokenStorage.saveTokens(
        accessToken: testAccessToken,
        refreshToken: testRefreshToken,
      );

      verify(
        () => mockSecureStorage.write(
          key: StorageKeys.accessToken,
          value: testAccessToken,
        ),
      ).called(1);
      verify(
        () => mockSecureStorage.write(
          key: StorageKeys.refreshToken,
          value: testRefreshToken,
        ),
      ).called(1);
    });

    test('getAccessToken retrieves token from secure storage', () async {
      when(
        () => mockSecureStorage.read(key: StorageKeys.accessToken),
      ).thenAnswer((_) async => testAccessToken);

      final token = await tokenStorage.getAccessToken();

      expect(token, testAccessToken);
      verify(
        () => mockSecureStorage.read(key: StorageKeys.accessToken),
      ).called(1);
    });

    test('getRefreshToken retrieves refresh token from secure storage', () async {
      when(
        () => mockSecureStorage.read(key: StorageKeys.refreshToken),
      ).thenAnswer((_) async => testRefreshToken);

      final token = await tokenStorage.getRefreshToken();

      expect(token, testRefreshToken);
      verify(
        () => mockSecureStorage.read(key: StorageKeys.refreshToken),
      ).called(1);
    });

    test('clearTokens removes access token, refresh token, and user profile', () async {
      when(
        () => mockSecureStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await tokenStorage.clearTokens();

      verify(
        () => mockSecureStorage.delete(key: StorageKeys.accessToken),
      ).called(1);
      verify(
        () => mockSecureStorage.delete(key: StorageKeys.refreshToken),
      ).called(1);
      verify(
        () => mockSecureStorage.delete(key: StorageKeys.userProfile),
      ).called(1);
    });

    test('saveUserProfile and getUserProfile store and retrieve json profile', () async {
      const userJson = '{"id":"1","name":"Test"}';
      when(
        () => mockSecureStorage.write(
          key: StorageKeys.userProfile,
          value: userJson,
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockSecureStorage.read(key: StorageKeys.userProfile),
      ).thenAnswer((_) async => userJson);

      await tokenStorage.saveUserProfile(userJson);
      final result = await tokenStorage.getUserProfile();

      expect(result, userJson);
      verify(
        () => mockSecureStorage.write(
          key: StorageKeys.userProfile,
          value: userJson,
        ),
      ).called(1);
      verify(
        () => mockSecureStorage.read(key: StorageKeys.userProfile),
      ).called(1);
    });

    test('getOrCreateDeviceId returns existing deviceId if found', () async {
      const existingDeviceId = '123e4567-e89b-12d3-a456-426614174000';
      when(
        () => mockSecureStorage.read(key: StorageKeys.deviceId),
      ).thenAnswer((_) async => existingDeviceId);

      final id = await tokenStorage.getOrCreateDeviceId();

      expect(id, existingDeviceId);
      verifyNever(
        () => mockSecureStorage.write(
          key: StorageKeys.deviceId,
          value: any(named: 'value'),
        ),
      );
    });

    test('getOrCreateDeviceId generates, writes and returns valid UUID v4 when empty', () async {
      when(
        () => mockSecureStorage.read(key: StorageKeys.deviceId),
      ).thenAnswer((_) async => null);

      when(
        () => mockSecureStorage.write(
          key: StorageKeys.deviceId,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final id = await tokenStorage.getOrCreateDeviceId();

      expect(id, isNotEmpty);
      // Valid RFC 4122 v4 regex: xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx
      final uuidV4Regex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidV4Regex.hasMatch(id), isTrue);

      verify(
        () => mockSecureStorage.write(
          key: StorageKeys.deviceId,
          value: id,
        ),
      ).called(1);
    });

    test('clearAll wipes entire secure storage', () async {
      when(() => mockSecureStorage.deleteAll()).thenAnswer((_) async {});

      await tokenStorage.clearAll();

      verify(() => mockSecureStorage.deleteAll()).called(1);
    });
  });
}
