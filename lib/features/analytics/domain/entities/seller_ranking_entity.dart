import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing seller ranking performance.
class SellerRankingEntity extends Equatable {
  final String sellerId;
  final String sellerName;
  final int totalOrders;
  final Decimal totalRevenue;
  final Decimal commissionEarned;
  final String revenueSharePercentage;

  const SellerRankingEntity({
    required this.sellerId,
    required this.sellerName,
    required this.totalOrders,
    required this.totalRevenue,
    required this.commissionEarned,
    required this.revenueSharePercentage,
  });

  /// Numeric representation of share percentage (0.0 to 100.0).
  double get shareValue {
    final cleaned = revenueSharePercentage.replaceAll('%', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  List<Object?> get props => [
        sellerId,
        sellerName,
        totalOrders,
        totalRevenue,
        commissionEarned,
        revenueSharePercentage,
      ];
}
