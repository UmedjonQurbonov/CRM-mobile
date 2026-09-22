import 'package:crm_mobile/core/errors/api_error.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiError', () {
    test('parses from valid RFC 7807 JSON map', () {
      final json = {
        'code': 'INVALID_CREDENTIALS',
        'message': 'Invalid phone or password',
        'details': {'field': 'phone', 'reason': 'must start with +992'},
      };

      final error = ApiError.fromJson(json);

      expect(error.code, 'INVALID_CREDENTIALS');
      expect(error.message, 'Invalid phone or password');
      expect(error.details?['field'], 'phone');
    });

    test('parses with defaults when fields are missing', () {
      final json = <String, dynamic>{};

      final error = ApiError.fromJson(json);

      expect(error.code, 'UNKNOWN_ERROR');
      expect(error.message, 'An unexpected error occurred');
      expect(error.details, isNull);
    });

    test('serializes to JSON correctly', () {
      const error = ApiError(
        code: 'USER_NOT_FOUND',
        message: 'Seller not found',
        details: {'id': '123'},
      );

      final json = error.toJson();

      expect(json['code'], 'USER_NOT_FOUND');
      expect(json['message'], 'Seller not found');
      expect(json['details'], {'id': '123'});
    });

    test('parses from DioException with backend response body', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          statusCode: 401,
          data: {
            'code': 'UNAUTHORIZED',
            'message': 'Invalid credentials supplied',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final error = ApiError.fromDioException(dioException);

      expect(error.code, 'UNAUTHORIZED');
      expect(error.message, 'Invalid credentials supplied');
    });

    test('parses from DioException connectionTimeout', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/orders'),
        type: DioExceptionType.connectionTimeout,
      );

      final error = ApiError.fromDioException(dioException);

      expect(error.code, 'CONNECTION_TIMEOUT');
      expect(error.toFailure(), isA<NetworkFailure>());
    });

    test('parses from DioException connectionError (no internet)', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/orders'),
        type: DioExceptionType.connectionError,
      );

      final error = ApiError.fromDioException(dioException);

      expect(error.code, 'NO_INTERNET');
      expect(error.toFailure(), isA<NetworkFailure>());
    });

    test('maps UNAUTHORIZED code to UnauthorizedFailure', () {
      const error = ApiError(
        code: 'UNAUTHORIZED',
        message: 'Session has expired',
      );

      final failure = error.toFailure();

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Session has expired');
    });

    test('maps generic codes to ServerFailure', () {
      const error = ApiError(
        code: 'INSUFFICIENT_STOCK',
        message: 'Product stock is 0',
      );

      final failure = error.toFailure();

      expect(failure, isA<ServerFailure>());
      expect(failure.code, 'INSUFFICIENT_STOCK');
    });
  });
}
