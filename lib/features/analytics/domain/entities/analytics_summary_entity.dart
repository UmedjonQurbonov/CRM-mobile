import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing P&L financial summary.
class AnalyticsSummaryEntity extends Equatable {
  final Decimal revenue;
  final Decimal costOfGoodsSold;
  final Decimal grossProfit;
  final Decimal totalExpenses;
  final Decimal totalCommissions;
  final Decimal netProfit;
  final int totalOrders;
  final DateTime? periodFrom;
  final DateTime? periodTo;

  const AnalyticsSummaryEntity({
    required this.revenue,
    required this.costOfGoodsSold,
    required this.grossProfit,
    required this.totalExpenses,
    required this.totalCommissions,
    required this.netProfit,
    required this.totalOrders,
    this.periodFrom,
    this.periodTo,
  });

  /// True if net profit is greater than or equal to zero.
  bool get isProfitable => netProfit >= Decimal.zero;

  @override
  List<Object?> get props => [
        revenue,
        costOfGoodsSold,
        grossProfit,
        totalExpenses,
        totalCommissions,
        netProfit,
        totalOrders,
        periodFrom,
        periodTo,
      ];
}
