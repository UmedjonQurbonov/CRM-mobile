import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:crm_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:crm_mobile/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:crm_mobile/features/orders/presentation/bloc/orders_event.dart';
import 'package:crm_mobile/features/orders/presentation/bloc/orders_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late MockOrdersRepository mockOrdersRepository;

  final sampleOrder1 = OrderEntity(
    id: 'order-1',
    sellerId: 'seller-1',
    totalAmount: Decimal.parse('500.00'),
    commissionRateSnapshot: Decimal.parse('5.00'),
    commissionEarned: Decimal.parse('25.00'),
    paymentMethod: 'cash',
    status: 'completed',
    items: const [],
  );

  final sampleRefundedOrder = OrderEntity(
    id: 'order-1',
    sellerId: 'seller-1',
    totalAmount: Decimal.parse('500.00'),
    commissionRateSnapshot: Decimal.parse('5.00'),
    commissionEarned: Decimal.parse('25.00'),
    paymentMethod: 'cash',
    status: 'refunded',
    items: const [],
  );

  final sampleOrderList = OrderListEntity(
    items: [sampleOrder1],
    total: 1,
    limit: 20,
    offset: 0,
  );

  setUp(() {
    mockOrdersRepository = MockOrdersRepository();
  });

  group('OrdersBloc', () {
    test('initial state is OrdersInitial', () {
      final bloc = OrdersBloc(ordersRepository: mockOrdersRepository);
      expect(bloc.state, const OrdersInitial());
      bloc.close();
    });

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersLoaded] on OrdersFetchRequested',
      build: () {
        when(
          () => mockOrdersRepository.getOrders(
            status: any(named: 'status'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            sellerId: any(named: 'sellerId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => sampleOrderList);
        return OrdersBloc(ordersRepository: mockOrdersRepository);
      },
      act: (bloc) => bloc.add(const OrdersFetchRequested()),
      expect: () => [
        const OrdersLoading(isFirstFetch: true),
        OrdersLoaded(
          orders: [sampleOrder1],
          total: 1,
          offset: 0,
          statusFilter: null,
          hasMore: false,
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersFailure] when fetching orders fails',
      build: () {
        when(
          () => mockOrdersRepository.getOrders(
            status: any(named: 'status'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            sellerId: any(named: 'sellerId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(const ServerFailure('Failed to load orders', code: 'SRV_ERR'));
        return OrdersBloc(ordersRepository: mockOrdersRepository);
      },
      act: (bloc) => bloc.add(const OrdersFetchRequested()),
      expect: () => [
        const OrdersLoading(isFirstFetch: true),
        const OrdersFailure('Failed to load orders', code: 'SRV_ERR'),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'successfully refunds order on OrderRefundRequested and re-fetches',
      build: () {
        when(() => mockOrdersRepository.refundOrder('order-1'))
            .thenAnswer((_) async => sampleRefundedOrder);

        when(
          () => mockOrdersRepository.getOrders(
            status: any(named: 'status'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            sellerId: any(named: 'sellerId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer(
          (_) async => OrderListEntity(
            items: [sampleRefundedOrder],
            total: 1,
            limit: 20,
            offset: 0,
          ),
        );

        return OrdersBloc(ordersRepository: mockOrdersRepository);
      },
      act: (bloc) => bloc.add(const OrderRefundRequested('order-1')),
      expect: () => [
        const OrdersLoading(isFirstFetch: false),
        OrderRefundSuccess(
          order: sampleRefundedOrder,
          message: 'Возврат по чеку успешно оформлен',
        ),
        OrdersLoaded(
          orders: [sampleRefundedOrder],
          total: 1,
          offset: 0,
          statusFilter: null,
          hasMore: false,
        ),
      ],
      verify: (_) {
        verify(() => mockOrdersRepository.refundOrder('order-1')).called(1);
      },
    );
  });
}
