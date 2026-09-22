import '../../../pos_checkout/domain/entities/cart_item_entity.dart';
import '../entities/order_entity.dart';

/// Abstract contract for orders and POS checkout operations.
abstract class OrdersRepository {
  /// Submits cart items for atomic order checkout and stock decrement.
  Future<OrderEntity> checkout({
    required List<CartItemEntity> items,
    required String paymentMethod,
  });

  /// Retrieves paginated list of orders with optional status, date, and seller filters.
  Future<OrderListEntity> getOrders({
    String? sellerId,
    String? status,
    String? startDate,
    String? endDate,
    int limit = 20,
    int offset = 0,
  });

  /// Retrieves specific order details by UUID.
  Future<OrderEntity> getOrderById(String id);

  /// Performs full order refund (Owner only) and restocks inventory.
  Future<OrderEntity> refundOrder(String id);
}
