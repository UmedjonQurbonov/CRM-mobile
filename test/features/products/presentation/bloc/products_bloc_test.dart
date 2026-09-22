import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/features/products/domain/entities/product_entity.dart';
import 'package:crm_mobile/features/products/domain/entities/product_params.dart';
import 'package:crm_mobile/features/products/domain/repositories/product_repository.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_bloc.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_event.dart';
import 'package:crm_mobile/features/products/presentation/bloc/products_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class FakeCreateProductParams extends Fake implements CreateProductParams {}

class FakeUpdateProductParams extends Fake implements UpdateProductParams {}

void main() {
  late MockProductRepository mockProductRepository;

  final sampleProduct1 = ProductEntity(
    id: 'prod-1',
    name: 'iPhone 15 Pro',
    sku: 'IPHONE-15P',
    qrCode: '111111111111',
    costPrice: Decimal.parse('9000.00'),
    sellingPrice: Decimal.parse('11500.00'),
    stockQuantity: 12,
    minStockAlert: 3,
    isLowStock: false,
    isActive: true,
  );

  final sampleProduct2 = ProductEntity(
    id: 'prod-2',
    name: 'EarPods Lightning',
    sku: 'EARPODS-LTG',
    qrCode: '222222222222',
    costPrice: Decimal.parse('120.00'),
    sellingPrice: Decimal.parse('200.00'),
    stockQuantity: 1,
    minStockAlert: 5,
    isLowStock: true,
    isActive: true,
  );

  final sampleListEntity = ProductListEntity(
    items: [sampleProduct1, sampleProduct2],
    total: 2,
    limit: 20,
    offset: 0,
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateProductParams());
    registerFallbackValue(FakeUpdateProductParams());
  });

  setUp(() {
    mockProductRepository = MockProductRepository();
  });

  group('ProductsBloc', () {
    test('initial state is ProductsInitial', () {
      final bloc = ProductsBloc(productRepository: mockProductRepository);
      expect(bloc.state, const ProductsInitial());
      bloc.close();
    });

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductsLoading(isFirstFetch: true), ProductsLoaded] on initial ProductsFetchRequested',
      build: () {
        when(
          () => mockProductRepository.getProducts(
            search: any(named: 'search'),
            lowStock: any(named: 'lowStock'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => sampleListEntity);
        return ProductsBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductsFetchRequested()),
      expect: () => [
        const ProductsLoading(isFirstFetch: true),
        ProductsLoaded(
          products: [sampleProduct1, sampleProduct2],
          total: 2,
          offset: 0,
          searchQuery: '',
          lowStockOnly: false,
          hasMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockProductRepository.getProducts(
            search: null,
            lowStock: null,
            limit: 20,
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductsLoading(isFirstFetch: true), ProductsFailure] when initial fetch fails',
      build: () {
        when(
          () => mockProductRepository.getProducts(
            search: any(named: 'search'),
            lowStock: any(named: 'lowStock'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(const ServerFailure('Failed to load catalog', code: 'SRV_ERR'));
        return ProductsBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductsFetchRequested()),
      expect: () => [
        const ProductsLoading(isFirstFetch: true),
        const ProductsFailure('Failed to load catalog', code: 'SRV_ERR'),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductsLoading, ProductsLoaded] with search query on ProductsExecuteSearch',
      build: () {
        when(
          () => mockProductRepository.getProducts(
            search: 'iPhone',
            lowStock: any(named: 'lowStock'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer(
          (_) async => ProductListEntity(
            items: [sampleProduct1],
            total: 1,
            limit: 20,
            offset: 0,
          ),
        );
        return ProductsBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductsExecuteSearch('iPhone')),
      expect: () => [
        const ProductsLoading(isFirstFetch: false),
        ProductsLoaded(
          products: [sampleProduct1],
          total: 1,
          offset: 0,
          searchQuery: 'iPhone',
          lowStockOnly: false,
          hasMore: false,
        ),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductsLoading, ProductsLoaded] toggling lowStock on ProductsLowStockToggled',
      build: () {
        when(
          () => mockProductRepository.getProducts(
            search: any(named: 'search'),
            lowStock: true,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer(
          (_) async => ProductListEntity(
            items: [sampleProduct2],
            total: 1,
            limit: 20,
            offset: 0,
          ),
        );
        return ProductsBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(const ProductsLowStockToggled()),
      expect: () => [
        const ProductsLoading(isFirstFetch: false),
        ProductsLoaded(
          products: [sampleProduct2],
          total: 1,
          offset: 0,
          searchQuery: '',
          lowStockOnly: true,
          hasMore: false,
        ),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'creates product, emits ProductActionSuccess and re-fetches products',
      build: () {
        when(
          () => mockProductRepository.createProduct(any()),
        ).thenAnswer((_) async => sampleProduct1);

        when(
          () => mockProductRepository.getProducts(
            search: any(named: 'search'),
            lowStock: any(named: 'lowStock'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => sampleListEntity);

        return ProductsBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(
        ProductCreateSubmitted(
          CreateProductParams(
            name: 'iPhone 15 Pro',
            sku: 'IPHONE-15P',
            qrCode: '111111111111',
            costPrice: Decimal.parse('9000.00'),
            sellingPrice: Decimal.parse('11500.00'),
            stockQuantity: 12,
            minStockAlert: 3,
          ),
        ),
      ),
      expect: () => [
        const ProductsLoading(isFirstFetch: false),
        ProductActionSuccess(
          message: 'Товар "iPhone 15 Pro" успешно добавлен',
          product: sampleProduct1,
        ),
        ProductsLoaded(
          products: [sampleProduct1, sampleProduct2],
          total: 2,
          offset: 0,
          searchQuery: '',
          lowStockOnly: false,
          hasMore: false,
        ),
      ],
      verify: (_) {
        verify(() => mockProductRepository.createProduct(any())).called(1);
      },
    );

    blocTest<ProductsBloc, ProductsState>(
      'updates product, emits ProductActionSuccess and re-fetches products',
      build: () {
        when(
          () => mockProductRepository.updateProduct(any(), any()),
        ).thenAnswer((_) async => sampleProduct2);

        when(
          () => mockProductRepository.getProducts(
            search: any(named: 'search'),
            lowStock: any(named: 'lowStock'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => sampleListEntity);

        return ProductsBloc(productRepository: mockProductRepository);
      },
      act: (bloc) => bloc.add(
        ProductUpdateSubmitted(
          id: 'prod-2',
          params: UpdateProductParams(
            name: 'EarPods Lightning Updated',
            sku: 'EARPODS-LTG',
            qrCode: '222222222222',
            costPrice: Decimal.parse('120.00'),
            sellingPrice: Decimal.parse('200.00'),
            stockQuantity: 1,
            minStockAlert: 5,
          ),
        ),
      ),
      expect: () => [
        const ProductsLoading(isFirstFetch: false),
        ProductActionSuccess(
          message: 'Товар "EarPods Lightning" обновлен',
          product: sampleProduct2,
        ),
        ProductsLoaded(
          products: [sampleProduct1, sampleProduct2],
          total: 2,
          offset: 0,
          searchQuery: '',
          lowStockOnly: false,
          hasMore: false,
        ),
      ],
      verify: (_) {
        verify(() => mockProductRepository.updateProduct('prod-2', any()))
            .called(1);
      },
    );
  });
}
