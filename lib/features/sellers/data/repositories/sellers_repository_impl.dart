import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/create_seller_params.dart';
import '../../domain/entities/seller_entity.dart';
import '../../domain/repositories/sellers_repository.dart';
import '../datasources/sellers_remote_data_source.dart';
import '../models/create_seller_request_model.dart';
import '../models/update_commission_request_model.dart';

/// Concrete repository implementation for staff sellers.
class SellersRepositoryImpl implements SellersRepository {
  final SellersRemoteDataSource remoteDataSource;

  SellersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SellerEntity>> getSellers() async {
    try {
      return await remoteDataSource.getSellers();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<SellerEntity> createSeller(CreateSellerParams params) async {
    try {
      final request = CreateSellerRequestModel.fromEntity(params);
      return await remoteDataSource.createSeller(request);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateCommission(String sellerId, Decimal newRate) async {
    try {
      final request = UpdateCommissionRequestModel.fromDecimal(newRate);
      await remoteDataSource.updateCommission(sellerId, request);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
