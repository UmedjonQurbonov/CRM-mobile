import '../entities/user_entity.dart';

/// Contract for authentication operations in domain layer.
abstract class AuthRepository {
  /// Logs in with phone and password. Throws a [Failure] subclass on error.
  Future<UserEntity> login({
    required String phone,
    required String password,
  });

  /// Logs out by revoking refresh token session and purging local storage.
  Future<void> logout();

  /// Verifies token presence and cached user on app launch.
  Future<UserEntity?> checkAuthStatus();

  /// Retrieves the currently cached user entity without network calls.
  Future<UserEntity?> getCurrentUser();
}
