import 'package:dio/dio.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_params.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/product_request_models.dart';

/// Concrete implementation of [ProductRepository].
class ProductRepositoryImpl implements ProductRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProductListEntity> getProducts({
    String? search,
    bool? lowStock,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await remoteDataSource.getProducts(
        search: search,
        lowStock: lowStock,
        limit: limit,
        offset: offset,
      );
      return response.toEntity();
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      throw apiError.toFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<ProductEntity> getProductByQr(String qrCode) async {
    try {
      final model = await remoteDataSource.getProductByQr(qrCode);
      return model.toEntity();
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      throw apiError.toFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<ProductEntity> createProduct(CreateProductParams params) async {
    try {
      final request = CreateProductRequestModel.fromParams(params);
      final model = await remoteDataSource.createProduct(request);
      return model.toEntity();
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      throw apiError.toFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<ProductEntity> updateProduct(
    String id,
    UpdateProductParams params,
  ) async {
    try {
      final request = UpdateProductRequestModel.fromParams(params);
      final model = await remoteDataSource.updateProduct(id, request);
      return model.toEntity();
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      throw apiError.toFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }
}
