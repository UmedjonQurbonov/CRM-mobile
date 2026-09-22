import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Single item within a completed order receipt.
class OrderItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final Decimal unitPrice;
  final Decimal subtotal;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        quantity,
        unitPrice,
        subtotal,
      ];
}

/// Domain entity representing a sales receipt / order.
class OrderEntity extends Equatable {
  final String id;
  final String sellerId;
  final Decimal totalAmount;
  final Decimal commissionRateSnapshot;
  final Decimal commissionEarned;
  final String paymentMethod;
  final String status;
  final List<OrderItemEntity> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    required this.id,
    required this.sellerId,
    required this.totalAmount,
    required this.commissionRateSnapshot,
    required this.commissionEarned,
    required this.paymentMethod,
    required this.status,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isRefunded => status == 'refunded';

  @override
  List<Object?> get props => [
        id,
        sellerId,
        totalAmount,
        commissionRateSnapshot,
        commissionEarned,
        paymentMethod,
        status,
        items,
        createdAt,
        updatedAt,
      ];
}

/// Paginated list of orders for sales history.
class OrderListEntity extends Equatable {
  final List<OrderEntity> items;
  final int total;
  final int limit;
  final int offset;

  const OrderListEntity({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  bool get hasMore => (offset + items.length) < total;

  @override
  List<Object?> get props => [items, total, limit, offset];
}
