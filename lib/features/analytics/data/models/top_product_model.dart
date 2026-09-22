import 'package:decimal/decimal.dart';
import '../../domain/entities/top_product_entity.dart';

/// Data model representing top product entry from API.
class TopProductModel extends TopProductEntity {
  const TopProductModel({
    required super.productId,
    required super.productName,
    required super.sku,
    required super.totalQuantitySold,
    required super.totalRevenue,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      totalQuantitySold: (json['total_quantity_sold'] as num?)?.toInt() ?? 0,
      totalRevenue: _parseDecimal(json['total_revenue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'total_quantity_sold': totalQuantitySold,
      'total_revenue': totalRevenue.toString(),
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
