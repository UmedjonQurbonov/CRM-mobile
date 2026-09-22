import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:crm_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:crm_mobile/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:crm_mobile/features/orders/presentation/bloc/orders_event.dart';
import 'package:crm_mobile/features/orders/presentation/bloc/orders_state.dart';
import 'package:crm_mobile/features/orders/presentation/screens/order_details_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockOrdersBloc extends MockBloc<OrdersEvent, OrdersState>
    implements OrdersBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockOrdersBloc mockOrdersBloc;

  final sampleOrder = OrderEntity(
    id: 'order-uuid-999',
    sellerId: 'seller-1',
    totalAmount: Decimal.parse('450.00'),
    commissionRateSnapshot: Decimal.parse('5.00'),
    commissionEarned: Decimal.parse('22.50'),
    paymentMethod: 'cash',
    status: 'completed',
    items: [
      OrderItemEntity(
        id: 'item-1',
        productId: 'prod-1',
        productName: 'Gaming Headset',
        quantity: 1,
        unitPrice: Decimal.parse('450.00'),
        subtotal: Decimal.parse('450.00'),
      ),
    ],
  );

  final sellerUser = UserEntity(
    id: 'seller-user',
    name: 'Seller Cashier',
    phone: '+992900000001',
    role: 'seller',
    commissionRate: Decimal.parse('5.00'),
  );

  final ownerUser = UserEntity(
    id: 'owner-user',
    name: 'Business Owner',
    phone: '+992900000002',
    role: 'owner',
    commissionRate: Decimal.zero,
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockOrdersBloc = MockOrdersBloc();
  });

  Widget buildTestWidget({required UserEntity user}) {
    when(() => mockAuthBloc.state).thenReturn(Authenticated(user));
    when(() => mockOrdersBloc.state).thenReturn(
      OrdersLoaded(
        orders: [sampleOrder],
        total: 1,
        offset: 0,
        hasMore: false,
      ),
    );

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<OrdersBloc>.value(value: mockOrdersBloc),
        ],
        child: OrderDetailsScreen(
          orderId: 'order-uuid-999',
          initialOrder: sampleOrder,
        ),
      ),
    );
  }

  group('OrderDetailsScreen RBAC Refund Button Visibility', () {
    testWidgets(
      'for SELLER role: refund button is strictly hidden',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(user: sellerUser));
        await tester.pump();

        expect(find.text('Чек #ORDER-UU'), findsOneWidget);
        expect(find.text('Gaming Headset'), findsOneWidget);
        expect(find.text('450.00 TJS'), findsWidgets);

        // Refund button must NOT exist for Seller
        expect(find.text('Оформить возврат (Owner)'), findsNothing);
      },
    );

    testWidgets(
      'for OWNER role: refund button is visible and opens confirmation dialog',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(user: ownerUser));
        await tester.pump();

        expect(find.text('Чек #ORDER-UU'), findsOneWidget);
        expect(find.text('Gaming Headset'), findsOneWidget);

        // Refund button is visible for Owner
        final refundBtn = find.text('Оформить возврат (Owner)');
        expect(refundBtn, findsOneWidget);

        // Tap refund button -> confirmation dialog appears
        await tester.tap(refundBtn);
        await tester.pump();

        expect(find.text('Подтверждение возврата'), findsOneWidget);
        expect(
          find.textContaining('Товары будут возвращены на склад.'),
          findsOneWidget,
        );
      },
    );
  });
}
