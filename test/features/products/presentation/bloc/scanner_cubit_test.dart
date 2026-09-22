import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/features/products/domain/entities/product_entity.dart';
import 'package:crm_mobile/features/products/domain/repositories/product_repository.dart';
import 'package:crm_mobile/features/products/presentation/bloc/scanner_cubit.dart';
import 'package:crm_mobile/features/products/presentation/bloc/scanner_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockProductRepository;

  final testProduct = ProductEntity(
    id: 'prod-123',
    name: 'AirPods Pro 2',
    sku: 'APP-2-WHT',
    qrCode: '190199220000',
    costPrice: Decimal.parse('1800.00'),
    sellingPrice: Decimal.parse('2400.00'),
    stockQuantity: 8,
    minStockAlert: 2,
    isLowStock: false,
    isActive: true,
  );

  setUp(() {
    mockProductRepository = MockProductRepository();
  });

  group('ScannerCubit', () {
    test('initial state is ScannerScanning', () {
      final cubit = ScannerCubit(productRepository: mockProductRepository);
      expect(cubit.state, const ScannerScanning());
      cubit.close();
    });

    blocTest<ScannerCubit, ScannerState>(
      'ignores empty or blank barcode detection',
      build: () => ScannerCubit(productRepository: mockProductRepository),
      act: (cubit) async {
        await cubit.onBarcodeDetected('');
        await cubit.onBarcodeDetected('   ');
      },
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(mockProductRepository);
      },
    );

    blocTest<ScannerCubit, ScannerState>(
      'emits [ScannerLoading, ScannerSuccess] when product is found by QR code',
      build: () {
        when(() => mockProductRepository.getProductByQr('190199220000'))
            .thenAnswer((_) async => testProduct);
        return ScannerCubit(productRepository: mockProductRepository);
      },
      act: (cubit) => cubit.onBarcodeDetected('190199220000'),
      expect: () => [
        const ScannerLoading('190199220000'),
        ScannerSuccess(testProduct),
      ],
      verify: (_) {
        verify(() => mockProductRepository.getProductByQr('190199220000'))
            .called(1);
      },
    );

    blocTest<ScannerCubit, ScannerState>(
      'emits [ScannerLoading, ScannerNotFound] when barcode is not found (404 / NOT_FOUND)',
      build: () {
        when(() => mockProductRepository.getProductByQr('999999999')).thenThrow(
          const ServerFailure(
            'Product not found',
            code: 'NOT_FOUND',
          ),
        );
        return ScannerCubit(productRepository: mockProductRepository);
      },
      act: (cubit) => cubit.onBarcodeDetected('999999999'),
      expect: () => [
        const ScannerLoading('999999999'),
        const ScannerNotFound(
          '999999999',
          'Товар со штрихкодом "999999999" не найден в номенклатуре.',
        ),
      ],
    );

    blocTest<ScannerCubit, ScannerState>(
      'emits [ScannerLoading, ScannerNotFound] when failure message contains not found',
      build: () {
        when(() => mockProductRepository.getProductByQr('888888888')).thenThrow(
          const ServerFailure('Item not found in inventory'),
        );
        return ScannerCubit(productRepository: mockProductRepository);
      },
      act: (cubit) => cubit.onBarcodeDetected('888888888'),
      expect: () => [
        const ScannerLoading('888888888'),
        const ScannerNotFound(
          '888888888',
          'Товар со штрихкодом "888888888" не найден в номенклатуре.',
        ),
      ],
    );

    blocTest<ScannerCubit, ScannerState>(
      'emits [ScannerLoading, ScannerError] on generic network failure',
      build: () {
        when(() => mockProductRepository.getProductByQr('12345')).thenThrow(
          const NetworkFailure('No internet connection'),
        );
        return ScannerCubit(productRepository: mockProductRepository);
      },
      act: (cubit) => cubit.onBarcodeDetected('12345'),
      expect: () => [
        const ScannerLoading('12345'),
        const ScannerError('No internet connection'),
      ],
    );

    test('resetScanner returns state to ScannerScanning', () {
      final cubit = ScannerCubit(productRepository: mockProductRepository);
      cubit.resetScanner();
      expect(cubit.state, const ScannerScanning());
      cubit.close();
    });
  });
}
