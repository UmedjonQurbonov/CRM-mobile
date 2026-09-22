import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/analytics/domain/entities/analytics_summary_entity.dart';
import 'package:crm_mobile/features/analytics/domain/entities/seller_ranking_entity.dart';
import 'package:crm_mobile/features/analytics/domain/entities/top_product_entity.dart';
import 'package:crm_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository mockRepository;
  late AnalyticsBloc analyticsBloc;

  final testSummary = AnalyticsSummaryEntity(
    revenue: Decimal.parse('12500.00'),
    costOfGoodsSold: Decimal.parse('7500.00'),
    grossProfit: Decimal.parse('5000.00'),
    totalExpenses: Decimal.parse('1200.00'),
    totalCommissions: Decimal.parse('850.00'),
    netProfit: Decimal.parse('2950.00'),
    totalOrders: 120,
    periodFrom: DateTime(2026, 9, 1),
    periodTo: DateTime(2026, 9, 22),
  );

  final testTopProducts = [
    TopProductEntity(
      productId: 'p-1',
      productName: 'T-Shirt',
      sku: 'TSH-001',
      totalQuantitySold: 50,
      totalRevenue: Decimal.parse('5000.00'),
    ),
  ];

  final testSellers = [
    SellerRankingEntity(
      sellerId: 's-1',
      sellerName: 'Umedjon',
      totalOrders: 40,
      totalRevenue: Decimal.parse('6000.00'),
      commissionEarned: Decimal.parse('600.00'),
      revenueSharePercentage: '50.00%',
    ),
  ];

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    analyticsBloc = AnalyticsBloc(analyticsRepository: mockRepository);
  });

  tearDown(() {
    analyticsBloc.close();
  });

  group('AnalyticsBloc', () {
    test('initial state is AnalyticsInitial', () {
      expect(analyticsBloc.state, const AnalyticsInitial());
    });

    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsLoaded] when AnalyticsFetchRequested succeeds',
      build: () {
        when(
          () => mockRepository.getSummary(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => testSummary);

        when(
          () => mockRepository.getTopProducts(
            from: any(named: 'from'),
            to: any(named: 'to'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => testTopProducts);

        when(
          () => mockRepository.getSellersRanking(
            from: any(named: 'from'),
            to: any(named: 'to'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => testSellers);

        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const AnalyticsFetchRequested()),
      expect: () => [
        const AnalyticsLoading(isFirstFetch: true),
        isA<AnalyticsLoaded>()
            .having((s) => s.summary.revenue, 'revenue', Decimal.parse('12500.00'))
            .having((s) => s.topProducts.length, 'topProducts count', 1)
            .having((s) => s.sellersRanking.length, 'sellersRanking count', 1),
      ],
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsFailure] when repository throws error',
      build: () {
        when(
          () => mockRepository.getSummary(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenThrow(Exception('Network error'));

        when(
          () => mockRepository.getTopProducts(
            from: any(named: 'from'),
            to: any(named: 'to'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        when(
          () => mockRepository.getSellersRanking(
            from: any(named: 'from'),
            to: any(named: 'to'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const AnalyticsFetchRequested()),
      expect: () => [
        const AnalyticsLoading(isFirstFetch: true),
        isA<AnalyticsFailure>(),
      ],
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'updates date bounds and re-fetches when AnalyticsPeriodChanged is added',
      build: () {
        when(
          () => mockRepository.getSummary(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => testSummary);

        when(
          () => mockRepository.getTopProducts(
            from: any(named: 'from'),
            to: any(named: 'to'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => testTopProducts);

        when(
          () => mockRepository.getSellersRanking(
            from: any(named: 'from'),
            to: any(named: 'to'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => testSellers);

        return analyticsBloc;
      },
      act: (bloc) => bloc.add(
        const AnalyticsPeriodChanged(periodType: AnalyticsPeriodType.today),
      ),
      expect: () => [
        const AnalyticsLoading(isFirstFetch: false),
        isA<AnalyticsLoaded>().having(
          (s) => s.periodType,
          'periodType',
          AnalyticsPeriodType.today,
        ),
      ],
    );
  });
}
