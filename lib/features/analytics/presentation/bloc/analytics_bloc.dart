import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../../domain/entities/seller_ranking_entity.dart';
import '../../domain/entities/top_product_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// BLoC orchestrating Owner's financial P&L analytics, rankings, and date period filtering.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository analyticsRepository;

  AnalyticsBloc({required this.analyticsRepository})
      : super(const AnalyticsInitial()) {
    on<AnalyticsFetchRequested>(_onFetchRequested);
    on<AnalyticsPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onFetchRequested(
    AnalyticsFetchRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    final currentState = state;
    DateTime? from = event.from;
    DateTime? to = event.to;
    AnalyticsPeriodType periodType = AnalyticsPeriodType.thisMonth;

    if (currentState is AnalyticsLoaded && from == null && to == null) {
      from = currentState.from;
      to = currentState.to;
      periodType = currentState.periodType;
    } else if (from == null && to == null) {
      final now = DateTime.now();
      from = DateTime(now.year, now.month, 1);
      to = DateTime(now.year, now.month, now.day);
      periodType = AnalyticsPeriodType.thisMonth;
    }

    if (!event.isRefresh) {
      emit(AnalyticsLoading(isFirstFetch: currentState is! AnalyticsLoaded));
    }

    try {
      final results = await Future.wait([
        analyticsRepository.getSummary(from: from, to: to),
        analyticsRepository.getTopProducts(from: from, to: to, limit: 10),
        analyticsRepository.getSellersRanking(from: from, to: to, limit: 10),
      ]);

      final summary = results[0] as AnalyticsSummaryEntity;
      final topProducts = results[1] as List<TopProductEntity>;
      final sellersRanking = results[2] as List<SellerRankingEntity>;

      emit(
        AnalyticsLoaded(
          summary: summary,
          topProducts: topProducts,
          sellersRanking: sellersRanking,
          periodType: periodType,
          from: from,
          to: to,
        ),
      );
    } catch (e) {
      emit(AnalyticsFailure(e.toString()));
    }
  }

  Future<void> _onPeriodChanged(
    AnalyticsPeriodChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    DateTime? from;
    DateTime? to;
    final now = DateTime.now();

    switch (event.periodType) {
      case AnalyticsPeriodType.today:
        from = DateTime(now.year, now.month, now.day);
        to = DateTime(now.year, now.month, now.day);
        break;
      case AnalyticsPeriodType.thisMonth:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month, now.day);
        break;
      case AnalyticsPeriodType.custom:
        from = event.customFrom;
        to = event.customTo;
        break;
    }

    emit(const AnalyticsLoading(isFirstFetch: false));

    try {
      final results = await Future.wait([
        analyticsRepository.getSummary(from: from, to: to),
        analyticsRepository.getTopProducts(from: from, to: to, limit: 10),
        analyticsRepository.getSellersRanking(from: from, to: to, limit: 10),
      ]);

      final summary = results[0] as AnalyticsSummaryEntity;
      final topProducts = results[1] as List<TopProductEntity>;
      final sellersRanking = results[2] as List<SellerRankingEntity>;

      emit(
        AnalyticsLoaded(
          summary: summary,
          topProducts: topProducts,
          sellersRanking: sellersRanking,
          periodType: event.periodType,
          from: from,
          to: to,
        ),
      );
    } catch (e) {
      emit(AnalyticsFailure(e.toString()));
    }
  }
}
