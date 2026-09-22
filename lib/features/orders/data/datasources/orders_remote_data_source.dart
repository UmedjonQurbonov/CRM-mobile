import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../pos_checkout/data/models/checkout_request_model.dart';
import '../models/order_list_response_model.dart';
import '../models/order_response_model.dart';

/// Remote data source interface for orders, POS checkout, and refunds.
abstract class OrdersRemoteDataSource {
  /// Posts checkout payload to create an order.
  Future<OrderResponseModel> checkout(CheckoutRequestModel request);

  /// Retrieves paginated orders list with query parameters.
  Future<OrderListResponseModel> getOrders({
    String? sellerId,
    String? status,
    String? startDate,
    String? endDate,
    int limit = 20,
    int offset = 0,
  });

  /// Retrieves order by ID.
  Future<OrderResponseModel> getOrderById(String id);

  /// Refunds order by ID (Owner only).
  Future<OrderResponseModel> refundOrder(String id);
}

/// Remote data source implementation using [DioClient].
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioClient client;

  OrdersRemoteDataSourceImpl({required this.client});

  @override
  Future<OrderResponseModel> checkout(CheckoutRequestModel request) async {
    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.orders,
      data: request.toJson(),
    );

    return OrderResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<OrderListResponseModel> getOrders({
    String? sellerId,
    String? status,
    String? startDate,
    String? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (sellerId != null && sellerId.isNotEmpty) {
      queryParams['seller_id'] = sellerId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }

    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.orders,
      queryParameters: queryParams,
    );

    return OrderListResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<OrderResponseModel> getOrderById(String id) async {
    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.orderById(id),
    );

    return OrderResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<OrderResponseModel> refundOrder(String id) async {
    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.orderRefund(id),
    );

    return OrderResponseModel.fromJson(response.data ?? {});
  }
}
