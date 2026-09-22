import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/analytics/domain/entities/seller_earnings_entity.dart';
import 'package:crm_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/my_earnings_bloc.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/my_earnings_event.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/my_earnings_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository mockRepository;
  late MyEarningsBloc myEarningsBloc;

  final testEarnings = SellerEarningsEntity(
    sellerId: 's-123',
    sellerName: 'Umedjon Qurbonov',
    commissionRate: '8.50%',
    totalSalesAmount: Decimal.parse('6500.00'),
    totalCommissionEarned: Decimal.parse('552.50'),
    ordersCount: 45,
    periodFrom: DateTime(2026, 9, 1),
    periodTo: DateTime(2026, 9, 22),
  );

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    myEarningsBloc = MyEarningsBloc(analyticsRepository: mockRepository);
  });

  tearDown(() {
    myEarningsBloc.close();
  });

  group('MyEarningsBloc', () {
    test('initial state is MyEarningsInitial', () {
      expect(myEarningsBloc.state, const MyEarningsInitial());
    });

    blocTest<MyEarningsBloc, MyEarningsState>(
      'emits [MyEarningsLoading, MyEarningsLoaded] when MyEarningsFetchRequested succeeds',
      build: () {
        when(
          () => mockRepository.getMyEarnings(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => testEarnings);

        return myEarningsBloc;
      },
      act: (bloc) => bloc.add(const MyEarningsFetchRequested()),
      expect: () => [
        const MyEarningsLoading(isFirstFetch: true),
        isA<MyEarningsLoaded>()
            .having((s) => s.earnings.sellerName, 'sellerName', 'Umedjon Qurbonov')
            .having((s) => s.earnings.commissionRate, 'commissionRate', '8.50%')
            .having((s) => s.earnings.totalCommissionEarned, 'totalCommissionEarned', Decimal.parse('552.50')),
      ],
    );

    blocTest<MyEarningsBloc, MyEarningsState>(
      'emits [MyEarningsLoading, MyEarningsFailure] when repository fails',
      build: () {
        when(
          () => mockRepository.getMyEarnings(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenThrow(Exception('Failed to load'));

        return myEarningsBloc;
      },
      act: (bloc) => bloc.add(const MyEarningsFetchRequested()),
      expect: () => [
        const MyEarningsLoading(isFirstFetch: true),
        isA<MyEarningsFailure>(),
      ],
    );

    blocTest<MyEarningsBloc, MyEarningsState>(
      'updates period and fetches when MyEarningsPeriodChanged is dispatched',
      build: () {
        when(
          () => mockRepository.getMyEarnings(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => testEarnings);

        return myEarningsBloc;
      },
      act: (bloc) => bloc.add(
        const MyEarningsPeriodChanged(periodType: AnalyticsPeriodType.today),
      ),
      expect: () => [
        const MyEarningsLoading(isFirstFetch: false),
        isA<MyEarningsLoaded>().having(
          (s) => s.periodType,
          'periodType',
          AnalyticsPeriodType.today,
        ),
      ],
    );
  });
}
