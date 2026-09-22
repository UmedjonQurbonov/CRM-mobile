import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

/// BLoC managing order receipts listing, status filtering, pagination, and Owner refunds.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository ordersRepository;

  OrdersBloc({required this.ordersRepository}) : super(const OrdersInitial()) {
    on<OrdersFetchRequested>(_onFetchRequested);
    on<OrderStatusFilterChanged>(_onStatusFilterChanged);
    on<OrderRefundRequested>(_onRefundRequested);
  }

  Future<void> _onFetchRequested(
    OrdersFetchRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    final isLoadMore = event.isLoadMore;

    String? activeStatus = event.status;
    int currentOffset = 0;

    if (currentState is OrdersLoaded) {
      activeStatus = event.status ?? currentState.statusFilter;
      if (isLoadMore) {
        if (!currentState.hasMore || currentState.isLoadingMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
        currentOffset = currentState.offset + currentState.orders.length;
      } else if (!event.refresh) {
        emit(const OrdersLoading(isFirstFetch: false));
      }
    } else if (!event.refresh) {
      emit(const OrdersLoading(isFirstFetch: true));
    }

    try {
      final result = await ordersRepository.getOrders(
        status: activeStatus,
        startDate: event.startDate,
        endDate: event.endDate,
        sellerId: event.sellerId,
        limit: 20,
        offset: currentOffset,
      );

      if (isLoadMore && currentState is OrdersLoaded) {
        final combined = List.of(currentState.orders)..addAll(result.items);
        emit(
          currentState.copyWith(
            orders: combined,
            total: result.total,
            offset: currentOffset,
            hasMore: result.hasMore,
            isLoadingMore: false,
            statusFilter: activeStatus,
          ),
        );
      } else {
        emit(
          OrdersLoaded(
            orders: result.items,
            total: result.total,
            offset: 0,
            statusFilter: activeStatus,
            hasMore: result.hasMore,
          ),
        );
      }
    } on Failure catch (f) {
      emit(OrdersFailure(f.message, code: f.code));
    } catch (e) {
      emit(OrdersFailure(e.toString()));
    }
  }

  void _onStatusFilterChanged(
    OrderStatusFilterChanged event,
    Emitter<OrdersState> emit,
  ) {
    add(OrdersFetchRequested(status: event.status, refresh: true));
  }

  Future<void> _onRefundRequested(
    OrderRefundRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading(isFirstFetch: false));

    try {
      final refundedOrder = await ordersRepository.refundOrder(event.orderId);
      emit(
        OrderRefundSuccess(
          order: refundedOrder,
          message: 'Возврат по чеку успешно оформлен',
        ),
      );
      add(const OrdersFetchRequested(refresh: true));
    } on Failure catch (f) {
      emit(OrdersFailure(f.message, code: f.code));
    } catch (e) {
      emit(OrdersFailure(e.toString()));
    }
  }
}
