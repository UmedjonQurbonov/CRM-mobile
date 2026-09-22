import 'package:dio/dio.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/failures.dart';
import '../../../pos_checkout/data/models/checkout_request_model.dart';
import '../../../pos_checkout/domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

/// Concrete implementation of [OrdersRepository] coordinating network calls.
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderEntity> checkout({
    required List<CartItemEntity> items,
    required String paymentMethod,
  }) async {
    try {
      final request = CheckoutRequestModel.fromEntities(
        items: items,
        paymentMethod: paymentMethod,
      );
      final model = await remoteDataSource.checkout(request);
      return model.toEntity();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<OrderListEntity> getOrders({
    String? sellerId,
    String? status,
    String? startDate,
    String? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final model = await remoteDataSource.getOrders(
        sellerId: sellerId,
        status: status,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<OrderEntity> getOrderById(String id) async {
    try {
      final model = await remoteDataSource.getOrderById(id);
      return model.toEntity();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<OrderEntity> refundOrder(String id) async {
    try {
      final model = await remoteDataSource.refundOrder(id);
      return model.toEntity();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
