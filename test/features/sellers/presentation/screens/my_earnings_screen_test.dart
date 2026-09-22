import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/analytics/domain/entities/seller_earnings_entity.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/my_earnings_bloc.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/my_earnings_event.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/my_earnings_state.dart';
import 'package:crm_mobile/features/sellers/presentation/screens/my_earnings_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMyEarningsBloc extends MockBloc<MyEarningsEvent, MyEarningsState>
    implements MyEarningsBloc {}

void main() {
  late MockMyEarningsBloc mockMyEarningsBloc;

  final testEarnings = SellerEarningsEntity(
    sellerId: 's-1',
    sellerName: 'Umedjon Qurbonov',
    commissionRate: '8.50%',
    totalSalesAmount: Decimal.parse('6500.00'),
    totalCommissionEarned: Decimal.parse('552.50'),
    ordersCount: 45,
    periodFrom: DateTime(2026, 9, 1),
    periodTo: DateTime(2026, 9, 22),
  );

  setUp(() {
    mockMyEarningsBloc = MockMyEarningsBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<MyEarningsBloc>.value(
        value: mockMyEarningsBloc,
        child: const MyEarningsScreen(),
      ),
    );
  }

  testWidgets('renders loading spinner when state is MyEarningsLoading', (tester) async {
    when(() => mockMyEarningsBloc.state).thenReturn(const MyEarningsLoading());

    await tester.pumpWidget(buildTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders seller name, commission rate, and payout amounts when loaded', (tester) async {
    when(() => mockMyEarningsBloc.state).thenReturn(
      MyEarningsLoaded(
        earnings: testEarnings,
        periodType: AnalyticsPeriodType.thisMonth,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Seller Name & Commission rate
    expect(find.text('Umedjon Qurbonov'), findsOneWidget);
    expect(find.text('Ваша ставка: 8.50%'), findsOneWidget);

    // Verify Commission Payout Card
    expect(find.text('Начислено к выплате'), findsOneWidget);
    expect(find.text('552.50 TJS'), findsOneWidget);

    // Verify Sales Metrics
    expect(find.text('6500.00 TJS'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
  });
}
