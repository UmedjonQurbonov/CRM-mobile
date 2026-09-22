import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'failures.dart';

/// Representation of the standard backend RFC 7807 error response:
/// `{ "code": "...", "message": "...", "details": { ... } }`
class ApiError extends Equatable {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  /// Creates an [ApiError] from a decoded JSON map.
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred',
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : null,
    );
  }

  /// Converts [ApiError] to a JSON-encodable map.
  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (details != null) 'details': details,
      };

  /// Parses an [ApiError] from a [DioException].
  factory ApiError.fromDioException(DioException exception) {
    // 1. If backend returned a structured JSON error response
    final responseData = exception.response?.data;
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('code') ||
          responseData.containsKey('message')) {
        return ApiError.fromJson(responseData);
      }
    }

    // 2. Handle specific DioException types
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiError(
          code: 'CONNECTION_TIMEOUT',
          message: 'Connection to server timed out. Please check your network.',
        );
      case DioExceptionType.sendTimeout:
        return const ApiError(
          code: 'SEND_TIMEOUT',
          message: 'Request send timeout. Please try again.',
        );
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          code: 'RECEIVE_TIMEOUT',
          message: 'Server response timeout. Please try again.',
        );
      case DioExceptionType.transformTimeout:
        return const ApiError(
          code: 'TRANSFORM_TIMEOUT',
          message: 'Request processing timeout. Please try again.',
        );
      case DioExceptionType.badCertificate:
        return const ApiError(
          code: 'BAD_CERTIFICATE',
          message: 'Security certificate verification failed.',
        );
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        return ApiError(
          code: 'HTTP_$statusCode',
          message: _messageForStatusCode(statusCode),
        );
      case DioExceptionType.cancel:
        return const ApiError(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled.',
        );
      case DioExceptionType.connectionError:
        return const ApiError(
          code: 'NO_INTERNET',
          message: 'Cannot connect to server. Check your internet connection.',
        );
      case DioExceptionType.unknown:
        return ApiError(
          code: 'UNKNOWN_ERROR',
          message: exception.message ?? 'An unexpected error occurred.',
        );
    }
  }

  static String _messageForStatusCode(int? statusCode) {
    return switch (statusCode) {
      400 => 'Bad request. Please verify input data.',
      401 => 'Unauthorized. Please login again.',
      403 => 'Access forbidden. You do not have permission for this action.',
      404 => 'Requested resource was not found.',
      409 => 'Conflict occurred with current resource state.',
      422 => 'Validation failed for submitted data.',
      500 => 'Internal server error. Please try again later.',
      502 => 'Bad gateway. Backend service may be restarting.',
      503 => 'Service temporarily unavailable.',
      _ => 'Server returned error status code: $statusCode',
    };
  }

  /// Converts [ApiError] to the corresponding Clean Architecture [Failure].
  Failure toFailure() {
    if (code == 'UNAUTHORIZED' || code == 'HTTP_401') {
      return UnauthorizedFailure(message, code: code);
    }
    if (code == 'NO_INTERNET' ||
        code == 'CONNECTION_TIMEOUT' ||
        code == 'RECEIVE_TIMEOUT' ||
        code == 'SEND_TIMEOUT') {
      return NetworkFailure(message, code: code);
    }
    return ServerFailure(message, code: code, details: details);
  }

  @override
  List<Object?> get props => [code, message, details];

  @override
  String toString() =>
      'ApiError(code: $code, message: $message, details: $details)';
}
