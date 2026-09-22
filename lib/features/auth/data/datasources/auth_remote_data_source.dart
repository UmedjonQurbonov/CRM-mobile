import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';

/// Remote data source interface for authentication endpoints.
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String phone,
    required String password,
    String? deviceId,
  });

  Future<void> logout({required String refreshToken});

  Future<AuthResponseModel> refresh({required String refreshToken});
}

/// Implementation using configured [DioClient].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthResponseModel> login({
    required String phone,
    required String password,
    String? deviceId,
  }) async {
    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'phone': phone,
        'password': password,
      },
      options: Options(
        headers: deviceId != null && deviceId.isNotEmpty
            ? {'X-Device-ID': deviceId}
            : null,
      ),
    );

    return AuthResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await client.post<dynamic>(
      ApiEndpoints.logout,
      data: {'refresh_token': refreshToken},
    );
  }

  @override
  Future<AuthResponseModel> refresh({required String refreshToken}) async {
    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );

    return AuthResponseModel.fromJson(response.data ?? {});
  }
}
