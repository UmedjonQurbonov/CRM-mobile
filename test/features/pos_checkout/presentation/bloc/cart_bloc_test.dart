import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/pos_checkout/domain/entities/cart_item_entity.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/cart_bloc.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/cart_event.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/cart_state.dart';
import 'package:crm_mobile/features/products/domain/entities/product_entity.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final product1 = ProductEntity(
    id: 'prod-1',
    name: 'Logitech Mouse',
    sku: 'LOG-M1',
    qrCode: '1001',
    costPrice: Decimal.parse('50.00'),
    sellingPrice: Decimal.parse('99.90'),
    stockQuantity: 5,
    minStockAlert: 2,
    isLowStock: false,
    isActive: true,
  );

  final product2 = ProductEntity(
    id: 'prod-2',
    name: 'Mechanical Keyboard',
    sku: 'KEY-M2',
    qrCode: '1002',
    costPrice: Decimal.parse('200.00'),
    sellingPrice: Decimal.parse('350.00'),
    stockQuantity: 2,
    minStockAlert: 1,
    isLowStock: false,
    isActive: true,
  );

  final outOfStockProduct = ProductEntity(
    id: 'prod-3',
    name: 'Sold Out Item',
    sku: 'ZERO-1',
    qrCode: '1003',
    costPrice: Decimal.parse('10.00'),
    sellingPrice: Decimal.parse('20.00'),
    stockQuantity: 0,
    minStockAlert: 5,
    isLowStock: true,
    isActive: true,
  );

  group('CartBloc', () {
    test('initial state is empty CartState with cash payment', () {
      final bloc = CartBloc();
      expect(bloc.state.isEmpty, isTrue);
      expect(bloc.state.totalItems, 0);
      expect(bloc.state.totalAmount, Decimal.zero);
      expect(bloc.state.paymentMethod, 'cash');
      bloc.close();
    });

    blocTest<CartBloc, CartState>(
      'adds product with quantity 1 on CartItemAdded',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(CartItemAdded(product1)),
      verify: (bloc) {
        expect(bloc.state.items.length, 1);
        expect(bloc.state.items.first.product.id, 'prod-1');
        expect(bloc.state.items.first.quantity, 1);
        expect(bloc.state.totalItems, 1);
        expect(bloc.state.totalAmount, Decimal.parse('99.90'));
      },
    );

    blocTest<CartBloc, CartState>(
      'increments quantity when existing item is added again',
      build: () => CartBloc(),
      act: (bloc) {
        bloc.add(CartItemAdded(product1, 1));
        bloc.add(CartItemAdded(product1, 2));
      },
      verify: (bloc) {
        expect(bloc.state.items.length, 1);
        expect(bloc.state.items.first.quantity, 3);
        expect(bloc.state.totalItems, 3);
        expect(bloc.state.totalAmount, Decimal.parse('299.70'));
      },
    );

    blocTest<CartBloc, CartState>(
      'clamps quantity to stockQuantity and sets warningMessage if adding exceeds stock',
      build: () => CartBloc(),
      act: (bloc) {
        // product2 has stockQuantity = 2
        bloc.add(CartItemAdded(product2, 5));
      },
      verify: (bloc) {
        expect(bloc.state.items.first.quantity, 2);
        expect(bloc.state.warningMessage, contains('Достигнут лимит склада'));
      },
    );

    blocTest<CartBloc, CartState>(
      'does not add out-of-stock product (stockQuantity <= 0) and sets warningMessage',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(CartItemAdded(outOfStockProduct)),
      verify: (bloc) {
        expect(bloc.state.items.isEmpty, isTrue);
        expect(bloc.state.warningMessage, contains('закончился на складе'));
      },
    );

    blocTest<CartBloc, CartState>(
      'updates quantity on CartQuantityChanged',
      build: () => CartBloc(),
      seed: () => CartState(
        items: [
          blocTestCartItem(product1, 1),
        ],
      ),
      act: (bloc) => bloc.add(const CartQuantityChanged('prod-1', 4)),
      verify: (bloc) {
        expect(bloc.state.items.first.quantity, 4);
      },
    );

    blocTest<CartBloc, CartState>(
      'removes item if CartQuantityChanged sets newQuantity to 0',
      build: () => CartBloc(),
      seed: () => CartState(
        items: [
          blocTestCartItem(product1, 2),
        ],
      ),
      act: (bloc) => bloc.add(const CartQuantityChanged('prod-1', 0)),
      verify: (bloc) {
        expect(bloc.state.items.isEmpty, isTrue);
      },
    );

    blocTest<CartBloc, CartState>(
      'removes item entirely on CartItemRemoved',
      build: () => CartBloc(),
      seed: () => CartState(
        items: [
          blocTestCartItem(product1, 1),
          blocTestCartItem(product2, 1),
        ],
      ),
      act: (bloc) => bloc.add(const CartItemRemoved('prod-1')),
      verify: (bloc) {
        expect(bloc.state.items.length, 1);
        expect(bloc.state.items.first.product.id, 'prod-2');
      },
    );

    blocTest<CartBloc, CartState>(
      'updates paymentMethod on CartPaymentMethodSelected',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(const CartPaymentMethodSelected('card')),
      expect: () => [
        const CartState(paymentMethod: 'card'),
      ],
    );

    blocTest<CartBloc, CartState>(
      'resets cart completely on CartCleared',
      build: () => CartBloc(),
      seed: () => CartState(
        items: [
          blocTestCartItem(product1, 3),
        ],
        paymentMethod: 'card',
      ),
      act: (bloc) => bloc.add(const CartCleared()),
      expect: () => [
        const CartState(),
      ],
    );
  });
}

dynamic blocTestCartItem(ProductEntity product, int quantity) {
  return product.toCartItem(quantity);
}

extension on ProductEntity {
  dynamic toCartItem(int qty) {
    return CartItemEntity(product: this, quantity: qty);
  }
}
