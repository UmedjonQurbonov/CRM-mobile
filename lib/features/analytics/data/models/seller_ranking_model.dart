import 'package:decimal/decimal.dart';
import '../../domain/entities/seller_ranking_entity.dart';

/// Data model representing seller ranking entry from API.
class SellerRankingModel extends SellerRankingEntity {
  const SellerRankingModel({
    required super.sellerId,
    required super.sellerName,
    required super.totalOrders,
    required super.totalRevenue,
    required super.commissionEarned,
    required super.revenueSharePercentage,
  });

  factory SellerRankingModel.fromJson(Map<String, dynamic> json) {
    return SellerRankingModel(
      sellerId: json['seller_id']?.toString() ?? '',
      sellerName: json['seller_name']?.toString() ?? '',
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalRevenue: _parseDecimal(json['total_revenue']),
      commissionEarned: _parseDecimal(json['commission_earned']),
      revenueSharePercentage: json['revenue_share_percentage']?.toString() ?? '0.00%',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'seller_name': sellerName,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue.toString(),
      'commission_earned': commissionEarned.toString(),
      'revenue_share_percentage': revenueSharePercentage,
    };
  }

  static Decimal _parseDecimal(dynamic value) {
    if (value == null) return Decimal.zero;
    if (value is Decimal) return value;
    final str = value.toString().trim();
    if (str.isEmpty) return Decimal.zero;
    return Decimal.tryParse(str) ?? Decimal.zero;
  }
}
