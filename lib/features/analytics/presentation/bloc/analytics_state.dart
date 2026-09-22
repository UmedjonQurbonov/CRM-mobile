import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../../domain/entities/seller_ranking_entity.dart';
import '../../domain/entities/top_product_entity.dart';
import 'analytics_event.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  final bool isFirstFetch;

  const AnalyticsLoading({this.isFirstFetch = true});

  @override
  List<Object?> get props => [isFirstFetch];
}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsSummaryEntity summary;
  final List<TopProductEntity> topProducts;
  final List<SellerRankingEntity> sellersRanking;
  final AnalyticsPeriodType periodType;
  final DateTime? from;
  final DateTime? to;

  const AnalyticsLoaded({
    required this.summary,
    required this.topProducts,
    required this.sellersRanking,
    this.periodType = AnalyticsPeriodType.thisMonth,
    this.from,
    this.to,
  });

  AnalyticsLoaded copyWith({
    AnalyticsSummaryEntity? summary,
    List<TopProductEntity>? topProducts,
    List<SellerRankingEntity>? sellersRanking,
    AnalyticsPeriodType? periodType,
    DateTime? from,
    DateTime? to,
  }) {
    return AnalyticsLoaded(
      summary: summary ?? this.summary,
      topProducts: topProducts ?? this.topProducts,
      sellersRanking: sellersRanking ?? this.sellersRanking,
      periodType: periodType ?? this.periodType,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        topProducts,
        sellersRanking,
        periodType,
        from,
        to,
      ];
}

class AnalyticsFailure extends AnalyticsState {
  final String message;

  const AnalyticsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
