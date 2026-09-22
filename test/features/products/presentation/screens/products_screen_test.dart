import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:crm_mobile/features/products/domain/entities/product_entity.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_bloc.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_event.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_state.dart';
import 'package:crm_mobile/features/products/presentation/screens/products_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProductsBloc extends MockBloc<ProductsEvent, ProductsState>
    implements ProductsBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProductsBloc mockProductsBloc;

  final testProduct = ProductEntity(
    id: 'prod-42',
    name: 'AirPods Pro 2',
    sku: 'APP-2',
    qrCode: '190199220000',
    costPrice: Decimal.parse('85.00'),
    sellingPrice: Decimal.parse('120.00'),
    stockQuantity: 15,
    minStockAlert: 5,
    isLowStock: false,
    isActive: true,
  );

  final testSeller = UserEntity(
    id: 'user-seller',
    name: 'Seller Agent',
    phone: '+992900000001',
    role: 'seller',
    commissionRate: Decimal.zero,
  );

  final testOwner = UserEntity(
    id: 'user-owner',
    name: 'Owner Admin',
    phone: '+992900000002',
    role: 'owner',
    commissionRate: Decimal.zero,
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProductsBloc = MockProductsBloc();
  });

  Widget buildTestWidget({required UserEntity user}) {
    when(() => mockAuthBloc.state).thenReturn(Authenticated(user));
    when(() => mockProductsBloc.state).thenReturn(
      ProductsLoaded(
        products: [testProduct],
        total: 1,
        offset: 0,
        searchQuery: '',
        lowStockOnly: false,
        hasMore: false,
      ),
    );

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<ProductsBloc>.value(value: mockProductsBloc),
        ],
        child: const ProductsScreen(),
      ),
    );
  }

  group('ProductsScreen Role-Based Rendering & Cost Price Masking', () {
    testWidgets(
      'for SELLER role: cost price is completely hidden and FAB is not shown',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(user: testSeller));
        await tester.pump();

        // 1. Selling price is visible
        expect(find.text('Цена продажи'), findsOneWidget);
        expect(find.text('120.00 TJS'), findsOneWidget);

        // 2. Cost price is strictly HIDDEN
        expect(find.text('Себестоимость'), findsNothing);
        expect(find.textContaining('85.00'), findsNothing);
        expect(find.text('0.00 TJS'), findsNothing);

        // 3. FloatingActionButton (Добавить товар) is hidden for seller
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.text('Добавить товар'), findsNothing);
      },
    );

    testWidgets(
      'for OWNER role: both selling price and cost price are visible, and FAB is shown',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(user: testOwner));
        await tester.pump();

        // 1. Selling price is visible
        expect(find.text('Цена продажи'), findsOneWidget);
        expect(find.text('120.00 TJS'), findsOneWidget);

        // 2. Cost price is visible for Owner
        expect(find.text('Себестоимость'), findsOneWidget);
        expect(find.text('85.00 TJS'), findsOneWidget);

        // 3. FloatingActionButton is visible for Owner
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Добавить товар'), findsOneWidget);
      },
    );
  });
}
