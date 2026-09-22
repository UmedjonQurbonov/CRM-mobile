import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/pos_checkout/domain/entities/cart_item_entity.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/cart_bloc.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/cart_event.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/cart_state.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/checkout_bloc.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/checkout_event.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/bloc/checkout_state.dart';
import 'package:crm_mobile/features/pos_checkout/presentation/screens/pos_screen.dart';
import 'package:crm_mobile/features/products/domain/entities/product_entity.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_bloc.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_event.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsBloc extends MockBloc<ProductsEvent, ProductsState>
    implements ProductsBloc {}

class MockCheckoutBloc extends MockBloc<CheckoutEvent, CheckoutState>
    implements CheckoutBloc {}

class MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

void main() {
  late MockProductsBloc mockProductsBloc;
  late MockCheckoutBloc mockCheckoutBloc;
  late MockCartBloc mockCartBloc;

  final inStockProduct = ProductEntity(
    id: 'prod-10',
    name: 'Wireless Keyboard',
    sku: 'W-KEY-1',
    qrCode: '990011',
    costPrice: Decimal.parse('100.00'),
    sellingPrice: Decimal.parse('180.00'),
    stockQuantity: 5,
    minStockAlert: 1,
    isLowStock: false,
    isActive: true,
  );

  final outOfStockProduct = ProductEntity(
    id: 'prod-20',
    name: 'Empty Stock Mouse',
    sku: 'MOU-0',
    qrCode: '990022',
    costPrice: Decimal.parse('50.00'),
    sellingPrice: Decimal.parse('90.00'),
    stockQuantity: 0,
    minStockAlert: 1,
    isLowStock: true,
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(const CartCleared());
  });

  setUp(() {
    mockProductsBloc = MockProductsBloc();
    mockCheckoutBloc = MockCheckoutBloc();
    mockCartBloc = MockCartBloc();
  });

  Widget buildTestWidget({
    List<ProductEntity>? products,
    CartState cartState = const CartState(),
  }) {
    when(() => mockProductsBloc.state).thenReturn(
      ProductsLoaded(
        products: products ?? [inStockProduct],
        total: (products ?? [inStockProduct]).length,
        offset: 0,
        searchQuery: '',
        lowStockOnly: false,
        hasMore: false,
      ),
    );
    when(() => mockCheckoutBloc.state).thenReturn(const CheckoutInitial());
    when(() => mockCartBloc.state).thenReturn(cartState);

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductsBloc>.value(value: mockProductsBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
          BlocProvider<CheckoutBloc>.value(value: mockCheckoutBloc),
        ],
        child: const PosScreen(),
      ),
    );
  }

  group('PosScreen POS Terminal Interaction', () {
    testWidgets(
      'renders product list with prices and stock, floating bar hidden when cart empty',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        expect(find.text('Кассовый Терминал (POS)'), findsOneWidget);
        expect(find.text('Wireless Keyboard'), findsOneWidget);
        expect(find.text('180.00 TJS'), findsOneWidget);
        expect(find.text('SKU: W-KEY-1 • Остаток: 5 шт.'), findsOneWidget);

        // Floating checkout bar is not visible
        expect(find.text('К оплате'), findsNothing);
      },
    );

    testWidgets(
      'tapping an in-stock product dispatches CartItemAdded to CartBloc',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        await tester.tap(find.text('Wireless Keyboard'));
        await tester.pump();

        verify(() => mockCartBloc.add(CartItemAdded(inStockProduct))).called(1);
      },
    );

    testWidgets(
      'displays in-cart badge and floating checkout bar when cart has items',
      (tester) async {
        final stateWithItem = CartState(
          items: [CartItemEntity(product: inStockProduct, quantity: 2)],
        );

        await tester.pumpWidget(buildTestWidget(cartState: stateWithItem));
        await tester.pump();

        // Product item badge
        expect(find.text('В чеке: 2'), findsOneWidget);

        // Floating bottom bar
        expect(find.text('2 шт. в чеке'), findsOneWidget);
        expect(find.text('360.00 TJS'), findsWidgets);
        expect(find.text('К оплате'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping an out-of-stock product does not dispatch CartItemAdded',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(products: [outOfStockProduct]),
        );
        await tester.pump();

        expect(find.text('Empty Stock Mouse'), findsOneWidget);
        expect(find.text('SKU: MOU-0 • Остаток: 0 шт.'), findsOneWidget);

        await tester.tap(find.text('Empty Stock Mouse'));
        await tester.pump();

        verifyNever(() => mockCartBloc.add(any()));
      },
    );
  });
}
