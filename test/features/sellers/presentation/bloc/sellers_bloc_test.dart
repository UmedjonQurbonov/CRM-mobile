import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/features/sellers/domain/entities/create_seller_params.dart';
import 'package:crm_mobile/features/sellers/domain/entities/seller_entity.dart';
import 'package:crm_mobile/features/sellers/domain/repositories/sellers_repository.dart';
import 'package:crm_mobile/features/sellers/presentation/bloc/sellers_bloc.dart';
import 'package:crm_mobile/features/sellers/presentation/bloc/sellers_event.dart';
import 'package:crm_mobile/features/sellers/presentation/bloc/sellers_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSellersRepository extends Mock implements SellersRepository {}

class FakeCreateSellerParams extends Fake implements CreateSellerParams {}

void main() {
  late MockSellersRepository mockSellersRepository;
  late SellersBloc sellersBloc;

  final sampleSeller = SellerEntity(
    id: 's-1',
    name: 'Alisher Saidov',
    phone: '+992900000001',
    role: 'seller',
    commissionRate: Decimal.parse('5.00'),
  );

  final sampleSeller2 = SellerEntity(
    id: 's-2',
    name: 'Dilshod Karimov',
    phone: '+992900000002',
    role: 'seller',
    commissionRate: Decimal.parse('8.00'),
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateSellerParams());
    registerFallbackValue(Decimal.zero);
  });

  setUp(() {
    mockSellersRepository = MockSellersRepository();
    sellersBloc = SellersBloc(sellersRepository: mockSellersRepository);
  });

  tearDown(() {
    sellersBloc.close();
  });

  group('SellersBloc Fetching', () {
    test('initial state is SellersInitial', () {
      expect(sellersBloc.state, const SellersInitial());
    });

    blocTest<SellersBloc, SellersState>(
      'emits [SellersLoading, SellersLoaded] on SellersFetchRequested',
      build: () {
        when(() => mockSellersRepository.getSellers())
            .thenAnswer((_) async => [sampleSeller, sampleSeller2]);
        return sellersBloc;
      },
      act: (bloc) => bloc.add(const SellersFetchRequested()),
      expect: () => [
        const SellersLoading(),
        SellersLoaded([sampleSeller, sampleSeller2]),
      ],
    );

    blocTest<SellersBloc, SellersState>(
      'emits [SellersLoading, SellersFailure] when getSellers fails',
      build: () {
        when(() => mockSellersRepository.getSellers())
            .thenThrow(const ServerFailure('Failed to load'));
        return sellersBloc;
      },
      act: (bloc) => bloc.add(const SellersFetchRequested()),
      expect: () => [
        const SellersLoading(),
        isA<SellersFailure>(),
      ],
    );
  });

  group('SellersBloc Mutations', () {
    final createParams = CreateSellerParams(
      name: 'Bobur',
      phone: '+992901112233',
      password: 'password123',
      commissionRate: Decimal.parse('6.00'),
    );

    final createdSeller = SellerEntity(
      id: 's-3',
      name: 'Bobur',
      phone: '+992901112233',
      role: 'seller',
      commissionRate: Decimal.parse('6.00'),
    );

    blocTest<SellersBloc, SellersState>(
      'creates seller and appends to existing list with success message',
      build: () {
        when(() => mockSellersRepository.createSeller(any()))
            .thenAnswer((_) async => createdSeller);
        return sellersBloc;
      },
      seed: () => SellersLoaded([sampleSeller]),
      act: (bloc) => bloc.add(SellerCreateSubmitted(createParams)),
      expect: () => [
        SellersLoaded(
          [sampleSeller, createdSeller],
          successMessage: 'Сотрудник Bobur успешно зарегистрирован',
        ),
      ],
    );

    blocTest<SellersBloc, SellersState>(
      'updates commission and updates list with success message',
      build: () {
        when(
          () => mockSellersRepository.updateCommission(
            's-1',
            Decimal.parse('10.00'),
          ),
        ).thenAnswer((_) async {});
        return sellersBloc;
      },
      seed: () => SellersLoaded([sampleSeller, sampleSeller2]),
      act: (bloc) => bloc.add(
        SellerCommissionUpdateSubmitted(
          sellerId: 's-1',
          newCommissionRate: Decimal.parse('10.00'),
        ),
      ),
      expect: () => [
        isA<SellersLoaded>()
            .having(
              (s) => s.sellers.firstWhere((x) => x.id == 's-1').commissionRate,
              'updated commission rate',
              Decimal.parse('10.00'),
            )
            .having(
              (s) => s.successMessage,
              'success message',
              'Ставка комиссии обновлена: 10.00%',
            ),
      ],
    );
  });
}
