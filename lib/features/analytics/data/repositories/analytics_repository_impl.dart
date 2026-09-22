import 'package:dio/dio.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../../domain/entities/seller_earnings_entity.dart';
import '../../domain/entities/seller_ranking_entity.dart';
import '../../domain/entities/top_product_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

/// Concrete repository implementation for analytics and personal earnings.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AnalyticsSummaryEntity> getSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return await remoteDataSource.getAnalyticsSummary(
        from: from,
        to: to,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<SellerRankingEntity>> getSellersRanking({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    try {
      return await remoteDataSource.getSellersRanking(
        from: from,
        to: to,
        limit: limit,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<TopProductEntity>> getTopProducts({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    try {
      return await remoteDataSource.getTopProducts(
        from: from,
        to: to,
        limit: limit,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<SellerEarningsEntity> getMyEarnings({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return await remoteDataSource.getMyEarnings(
        from: from,
        to: to,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
