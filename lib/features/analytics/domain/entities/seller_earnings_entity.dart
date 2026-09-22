import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing caller seller's personal earnings.
class SellerEarningsEntity extends Equatable {
  final String sellerId;
  final String sellerName;
  final String commissionRate;
  final Decimal totalSalesAmount;
  final Decimal totalCommissionEarned;
  final int ordersCount;
  final DateTime? periodFrom;
  final DateTime? periodTo;

  const SellerEarningsEntity({
    required this.sellerId,
    required this.sellerName,
    required this.commissionRate,
    required this.totalSalesAmount,
    required this.totalCommissionEarned,
    required this.ordersCount,
    this.periodFrom,
    this.periodTo,
  });

  @override
  List<Object?> get props => [
        sellerId,
        sellerName,
        commissionRate,
        totalSalesAmount,
        totalCommissionEarned,
        ordersCount,
        periodFrom,
        periodTo,
      ];
}
