import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<UserEntity> login({
    required String phone,
    required String password,
  }) async {
    try {
      final deviceId = await tokenStorage.getOrCreateDeviceId();

      final response = await remoteDataSource.login(
        phone: phone,
        password: password,
        deviceId: deviceId,
      );

      // Persist access and refresh tokens
      await tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );

      // Persist cached user profile JSON
      await tokenStorage.saveUserProfile(jsonEncode(response.user.toJson()));

      return response.user.toEntity();
    } on DioException catch (dioException) {
      final apiError = ApiError.fromDioException(dioException);
      throw apiError.toFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await remoteDataSource.logout(refreshToken: refreshToken);
      }
    } catch (_) {
      // Regardless of remote error or offline state, local tokens must be purged
    } finally {
      await tokenStorage.clearTokens();
    }
  }

  @override
  Future<UserEntity?> checkAuthStatus() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();

      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        await tokenStorage.clearTokens();
        return null;
      }

      return await getCurrentUser();
    } catch (_) {
      await tokenStorage.clearTokens();
      return null;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final profileJson = await tokenStorage.getUserProfile();
      if (profileJson != null && profileJson.isNotEmpty) {
        final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
        return UserModel.fromJson(decoded).toEntity();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
