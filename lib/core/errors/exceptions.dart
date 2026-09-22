/// Exception thrown by data layer when server returns an error.
class ServerException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  const ServerException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'ServerException(code: $code, message: $message, details: $details)';
}

/// Exception thrown when authentication fails or token cannot be refreshed.
class UnauthorizedException implements Exception {
  final String message;
  final String? code;

  const UnauthorizedException(this.message, {this.code});

  @override
  String toString() => 'UnauthorizedException(code: $code, message: $message)';
}

/// Exception thrown on network connectivity issues or timeouts.
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network connection error']);

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Exception thrown on secure storage read/write errors.
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache storage error']);

  @override
  String toString() => 'CacheException(message: $message)';
}
