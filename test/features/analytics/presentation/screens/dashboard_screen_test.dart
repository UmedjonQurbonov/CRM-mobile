import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/features/analytics/domain/entities/analytics_summary_entity.dart';
import 'package:crm_mobile/features/analytics/domain/entities/seller_ranking_entity.dart';
import 'package:crm_mobile/features/analytics/domain/entities/top_product_entity.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:crm_mobile/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:crm_mobile/features/analytics/presentation/screens/dashboard_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsBloc extends MockBloc<AnalyticsEvent, AnalyticsState>
    implements AnalyticsBloc {}

void main() {
  late MockAnalyticsBloc mockAnalyticsBloc;

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
      productName: 'T-Shirt White',
      sku: 'TSH-001',
      totalQuantitySold: 85,
      totalRevenue: Decimal.parse('12750.00'),
    ),
  ];

  final testSellers = [
    SellerRankingEntity(
      sellerId: 's-1',
      sellerName: 'Umedjon Qurbonov',
      totalOrders: 45,
      totalRevenue: Decimal.parse('6500.00'),
      commissionEarned: Decimal.parse('552.50'),
      revenueSharePercentage: '52.00%',
    ),
  ];

  setUp(() {
    mockAnalyticsBloc = MockAnalyticsBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<AnalyticsBloc>.value(
        value: mockAnalyticsBloc,
        child: const DashboardScreen(),
      ),
    );
  }

  testWidgets('renders loading spinner when state is AnalyticsLoading', (tester) async {
    when(() => mockAnalyticsBloc.state).thenReturn(const AnalyticsLoading());

    await tester.pumpWidget(buildTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders P&L metrics, period chips, and rankings when AnalyticsLoaded', (tester) async {
    when(() => mockAnalyticsBloc.state).thenReturn(
      AnalyticsLoaded(
        summary: testSummary,
        topProducts: testTopProducts,
        sellersRanking: testSellers,
        periodType: AnalyticsPeriodType.thisMonth,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Period Chips
    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Текущий месяц'), findsOneWidget);

    // Verify P&L Metric titles and formulas
    expect(find.text('Выручка (R)'), findsOneWidget);
    expect(find.text('12500.00 TJS'), findsOneWidget);
    expect(find.text('Валовая прибыль (GP)'), findsOneWidget);
    expect(find.text('5000.00 TJS'), findsOneWidget);
    expect(find.text('Чистая прибыль (NP)'), findsOneWidget);
    expect(find.text('2950.00 TJS'), findsOneWidget);
    expect(find.text('Прибыль'), findsOneWidget);

    // Verify Rankings TabBar
    expect(find.text('Топ товаров'), findsOneWidget);
    expect(find.text('Рейтинг продавцов'), findsOneWidget);

    // Verify Top Products content
    expect(find.text('T-Shirt White'), findsOneWidget);
    expect(find.text('SKU: TSH-001'), findsOneWidget);
  });
}
