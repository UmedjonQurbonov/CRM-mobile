import 'package:decimal/decimal.dart';
import '../../domain/entities/analytics_summary_entity.dart';

/// Data model representing P&L summary from backend API.
class AnalyticsSummaryModel extends AnalyticsSummaryEntity {
  const AnalyticsSummaryModel({
    required super.revenue,
    required super.costOfGoodsSold,
    required super.grossProfit,
    required super.totalExpenses,
    required super.totalCommissions,
    required super.netProfit,
    required super.totalOrders,
    super.periodFrom,
    super.periodTo,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      revenue: _parseDecimal(json['revenue']),
      costOfGoodsSold: _parseDecimal(json['cost_of_goods_sold']),
      grossProfit: _parseDecimal(json['gross_profit']),
      totalExpenses: _parseDecimal(json['total_expenses']),
      totalCommissions: _parseDecimal(json['total_commissions']),
      netProfit: _parseDecimal(json['net_profit']),
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      periodFrom: _parseDate(json['period_from']),
      periodTo: _parseDate(json['period_to']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue.toString(),
      'cost_of_goods_sold': costOfGoodsSold.toString(),
      'gross_profit': grossProfit.toString(),
      'total_expenses': totalExpenses.toString(),
      'total_commissions': totalCommissions.toString(),
      'net_profit': netProfit.toString(),
      'total_orders': totalOrders,
      if (periodFrom != null)
        'period_from': periodFrom!.toIso8601String().split('T').first,
      if (periodTo != null)
        'period_to': periodTo!.toIso8601String().split('T').first,
    };
  }

  static Decimal _parseDecimal(dynamic value) {
    if (value == null) return Decimal.zero;
    if (value is Decimal) return value;
    final str = value.toString().trim();
    if (str.isEmpty) return Decimal.zero;
    return Decimal.tryParse(str) ?? Decimal.zero;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
