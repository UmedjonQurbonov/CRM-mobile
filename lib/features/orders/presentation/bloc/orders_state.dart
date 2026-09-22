import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

/// Base state for Orders history management.
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any orders request.
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Loading state for initial fetch or filter change.
class OrdersLoading extends OrdersState {
  final bool isFirstFetch;

  const OrdersLoading({this.isFirstFetch = true});

  @override
  List<Object?> get props => [isFirstFetch];
}

/// Orders successfully loaded with pagination metadata.
class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final int total;
  final int offset;
  final String? statusFilter;
  final bool hasMore;
  final bool isLoadingMore;

  const OrdersLoaded({
    required this.orders,
    required this.total,
    required this.offset,
    this.statusFilter,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  OrdersLoaded copyWith({
    List<OrderEntity>? orders,
    int? total,
    int? offset,
    String? statusFilter,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      statusFilter: statusFilter ?? this.statusFilter,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        total,
        offset,
        statusFilter,
        hasMore,
        isLoadingMore,
      ];
}

/// Order refund succeeded.
class OrderRefundSuccess extends OrdersState {
  final OrderEntity order;
  final String message;

  const OrderRefundSuccess({
    required this.order,
    required this.message,
  });

  @override
  List<Object?> get props => [order, message];
}

/// Orders or refund operation failure.
class OrdersFailure extends OrdersState {
  final String message;
  final String? code;

  const OrdersFailure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
