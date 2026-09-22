import 'package:decimal/decimal.dart';
import '../../domain/entities/seller_earnings_entity.dart';

/// Data model representing calling seller's earnings from API.
class SellerEarningsModel extends SellerEarningsEntity {
  const SellerEarningsModel({
    required super.sellerId,
    required super.sellerName,
    required super.commissionRate,
    required super.totalSalesAmount,
    required super.totalCommissionEarned,
    required super.ordersCount,
    super.periodFrom,
    super.periodTo,
  });

  factory SellerEarningsModel.fromJson(Map<String, dynamic> json) {
    return SellerEarningsModel(
      sellerId: json['seller_id']?.toString() ?? '',
      sellerName: json['seller_name']?.toString() ?? '',
      commissionRate: json['commission_rate']?.toString() ?? '0.00%',
      totalSalesAmount: _parseDecimal(json['total_sales_amount']),
      totalCommissionEarned: _parseDecimal(json['total_commission_earned']),
      ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
      periodFrom: _parseDate(json['period_from']),
      periodTo: _parseDate(json['period_to']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'seller_name': sellerName,
      'commission_rate': commissionRate,
      'total_sales_amount': totalSalesAmount.toString(),
      'total_commission_earned': totalCommissionEarned.toString(),
      'orders_count': ordersCount,
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
