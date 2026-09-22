import 'package:equatable/equatable.dart';

/// Base event for Orders history management.
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Requests fetching or refreshing the list of sales orders.
class OrdersFetchRequested extends OrdersEvent {
  final bool refresh;
  final bool isLoadMore;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? sellerId;

  const OrdersFetchRequested({
    this.refresh = false,
    this.isLoadMore = false,
    this.status,
    this.startDate,
    this.endDate,
    this.sellerId,
  });

  @override
  List<Object?> get props => [
        refresh,
        isLoadMore,
        status,
        startDate,
        endDate,
        sellerId,
      ];
}

/// Changes the active status filter (e.g. 'completed', 'refunded', or null).
class OrderStatusFilterChanged extends OrdersEvent {
  final String? status;

  const OrderStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

/// Submits an order refund request (Owner only).
class OrderRefundRequested extends OrdersEvent {
  final String orderId;

  const OrderRefundRequested(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
