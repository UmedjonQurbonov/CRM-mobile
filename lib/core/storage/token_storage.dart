import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

/// Secure token and device storage service using [FlutterSecureStorage].
class TokenStorage {
  final FlutterSecureStorage _secureStorage;

  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Persists new access and refresh tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: StorageKeys.accessToken, value: accessToken),
      _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  /// Retrieves the current access token.
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: StorageKeys.accessToken);
  }

  /// Retrieves the current refresh token.
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: StorageKeys.refreshToken);
  }

  /// Deletes access and refresh tokens (e.g., on logout or 401 unauthenticated).
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: StorageKeys.accessToken),
      _secureStorage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  /// Returns existing persistent device ID or generates, saves, and returns a new RFC 4122 v4 UUID.
  Future<String> getOrCreateDeviceId() async {
    final existingId = await _secureStorage.read(key: StorageKeys.deviceId);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final newId = _generateUuidV4();
    await _secureStorage.write(key: StorageKeys.deviceId, value: newId);
    return newId;
  }

  /// Clears all stored data (tokens, device id, cached role/user).
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  /// Cryptographically secure RFC 4122 v4 UUID generator.
  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant RFC 4122

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
