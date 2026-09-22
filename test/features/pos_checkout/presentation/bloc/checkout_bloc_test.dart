import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:crm_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:crm_mobile/features/pos_checkout/domain/entities/cart_item_entity.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/checkout_bloc.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/checkout_event.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/checkout_state.dart';
import 'package:crm_mobile/features/products/domain/entities/product_entity.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late MockOrdersRepository mockOrdersRepository;

  final product = ProductEntity(
    id: 'prod-1',
    name: 'EarPods',
    sku: 'EAR-1',
    qrCode: '1001',
    costPrice: Decimal.parse('50.00'),
    sellingPrice: Decimal.parse('150.00'),
    stockQuantity: 10,
    minStockAlert: 2,
    isLowStock: false,
    isActive: true,
  );

  final cartItems = [
    CartItemEntity(product: product, quantity: 2),
  ];

  final sampleOrder = OrderEntity(
    id: 'order-123',
    sellerId: 'seller-1',
    totalAmount: Decimal.parse('300.00'),
    commissionRateSnapshot: Decimal.parse('5.00'),
    commissionEarned: Decimal.parse('15.00'),
    paymentMethod: 'cash',
    status: 'completed',
    items: [
      OrderItemEntity(
        id: 'item-1',
        productId: 'prod-1',
        productName: 'EarPods',
        quantity: 2,
        unitPrice: Decimal.parse('150.00'),
        subtotal: Decimal.parse('300.00'),
      ),
    ],
  );

  setUp(() {
    mockOrdersRepository = MockOrdersRepository();
  });

  group('CheckoutBloc', () {
    test('initial state is CheckoutInitial', () {
      final bloc = CheckoutBloc(ordersRepository: mockOrdersRepository);
      expect(bloc.state, const CheckoutInitial());
      bloc.close();
    });

    blocTest<CheckoutBloc, CheckoutState>(
      'emits CheckoutFailure if cart items are empty',
      build: () => CheckoutBloc(ordersRepository: mockOrdersRepository),
      act: (bloc) => bloc.add(
        const CheckoutSubmitted(items: [], paymentMethod: 'cash'),
      ),
      expect: () => [
        const CheckoutFailure('Корзина пуста. Добавьте товары для продажи.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockOrdersRepository);
      },
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits [CheckoutLoading, CheckoutSuccess] on successful checkout',
      build: () {
        when(
          () => mockOrdersRepository.checkout(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
          ),
        ).thenAnswer((_) async => sampleOrder);
        return CheckoutBloc(ordersRepository: mockOrdersRepository);
      },
      act: (bloc) => bloc.add(
        CheckoutSubmitted(items: cartItems, paymentMethod: 'cash'),
      ),
      expect: () => [
        const CheckoutLoading(),
        CheckoutSuccess(sampleOrder),
      ],
      verify: (_) {
        verify(
          () => mockOrdersRepository.checkout(
            items: cartItems,
            paymentMethod: 'cash',
          ),
        ).called(1);
      },
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits [CheckoutLoading, CheckoutFailure] when stock is insufficient (409 INSUFFICIENT_STOCK)',
      build: () {
        when(
          () => mockOrdersRepository.checkout(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
          ),
        ).thenThrow(
          const ServerFailure(
            'Товара недостаточно на складе',
            code: 'INSUFFICIENT_STOCK',
          ),
        );
        return CheckoutBloc(ordersRepository: mockOrdersRepository);
      },
      act: (bloc) => bloc.add(
        CheckoutSubmitted(items: cartItems, paymentMethod: 'card'),
      ),
      expect: () => [
        const CheckoutLoading(),
        const CheckoutFailure(
          'Товара недостаточно на складе',
          code: 'INSUFFICIENT_STOCK',
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'resets to CheckoutInitial on CheckoutReset',
      build: () => CheckoutBloc(ordersRepository: mockOrdersRepository),
      seed: () => CheckoutSuccess(sampleOrder),
      act: (bloc) => bloc.add(const CheckoutReset()),
      expect: () => [
        const CheckoutInitial(),
      ],
    );
  });
}
