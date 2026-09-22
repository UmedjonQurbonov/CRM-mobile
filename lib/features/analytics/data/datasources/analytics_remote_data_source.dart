import 'package:intl/intl.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/analytics_summary_model.dart';
import '../models/seller_earnings_model.dart';
import '../models/seller_ranking_model.dart';
import '../models/top_product_model.dart';

/// Interface for analytics and earnings remote data source.
abstract interface class AnalyticsRemoteDataSource {
  Future<AnalyticsSummaryModel> getAnalyticsSummary({
    DateTime? from,
    DateTime? to,
  });

  Future<List<SellerRankingModel>> getSellersRanking({
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  Future<List<TopProductModel>> getTopProducts({
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  Future<SellerEarningsModel> getMyEarnings({
    DateTime? from,
    DateTime? to,
  });
}

/// Remote data source implementation using configured [DioClient].
class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final DioClient client;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  AnalyticsRemoteDataSourceImpl({required this.client});

  @override
  Future<AnalyticsSummaryModel> getAnalyticsSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, dynamic>{};
    if (from != null) {
      queryParams['from'] = _dateFormat.format(from);
    }
    if (to != null) {
      queryParams['to'] = _dateFormat.format(to);
    }

    final response = await client.get(
      ApiEndpoints.analyticsSummary,
      queryParameters: queryParams,
    );

    return AnalyticsSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<SellerRankingModel>> getSellersRanking({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (from != null) {
      queryParams['from'] = _dateFormat.format(from);
    }
    if (to != null) {
      queryParams['to'] = _dateFormat.format(to);
    }
    if (limit != null) {
      queryParams['limit'] = limit;
    }

    final response = await client.get(
      ApiEndpoints.sellersRanking,
      queryParameters: queryParams,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((item) => SellerRankingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TopProductModel>> getTopProducts({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (from != null) {
      queryParams['from'] = _dateFormat.format(from);
    }
    if (to != null) {
      queryParams['to'] = _dateFormat.format(to);
    }
    if (limit != null) {
      queryParams['limit'] = limit;
    }

    final response = await client.get(
      ApiEndpoints.topProducts,
      queryParameters: queryParams,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((item) => TopProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SellerEarningsModel> getMyEarnings({
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, dynamic>{};
    if (from != null) {
      queryParams['from'] = _dateFormat.format(from);
    }
    if (to != null) {
      queryParams['to'] = _dateFormat.format(to);
    }

    final response = await client.get(
      ApiEndpoints.myEarnings,
      queryParameters: queryParams,
    );

    return SellerEarningsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
