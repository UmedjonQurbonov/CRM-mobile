import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing top selling products.
class TopProductEntity extends Equatable {
  final String productId;
  final String productName;
  final String sku;
  final int totalQuantitySold;
  final Decimal totalRevenue;

  const TopProductEntity({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        sku,
        totalQuantitySold,
        totalRevenue,
      ];
}
