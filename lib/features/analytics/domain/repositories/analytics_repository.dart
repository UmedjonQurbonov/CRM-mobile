import '../entities/analytics_summary_entity.dart';
import '../entities/seller_earnings_entity.dart';
import '../entities/seller_ranking_entity.dart';
import '../entities/top_product_entity.dart';

/// Contract for business financial analytics and personal earnings.
abstract interface class AnalyticsRepository {
  /// Fetches financial P&L summary for the given date range (Owner only).
  Future<AnalyticsSummaryEntity> getSummary({
    DateTime? from,
    DateTime? to,
  });

  /// Fetches ranked list of sellers by revenue performance (Owner only).
  Future<List<SellerRankingEntity>> getSellersRanking({
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  /// Fetches top products ranked by sales revenue (Owner only).
  Future<List<TopProductEntity>> getTopProducts({
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  /// Fetches personal earnings statistics for the calling seller (Seller & Owner).
  Future<SellerEarningsEntity> getMyEarnings({
    DateTime? from,
    DateTime? to,
  });
}
