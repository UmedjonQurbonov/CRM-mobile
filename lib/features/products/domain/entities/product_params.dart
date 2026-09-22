import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Parameters for creating a new product.
class CreateProductParams extends Equatable {
  final String name;
  final String sku;
  final String qrCode;
  final Decimal costPrice;
  final Decimal sellingPrice;
  final int stockQuantity;
  final int minStockAlert;

  const CreateProductParams({
    required this.name,
    required this.sku,
    required this.qrCode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockAlert,
  });

  @override
  List<Object?> get props => [
        name,
        sku,
        qrCode,
        costPrice,
        sellingPrice,
        stockQuantity,
        minStockAlert,
      ];
}

/// Parameters for updating an existing product.
class UpdateProductParams extends Equatable {
  final String name;
  final String sku;
  final String qrCode;
  final Decimal costPrice;
  final Decimal sellingPrice;
  final int stockQuantity;
  final int minStockAlert;

  const UpdateProductParams({
    required this.name,
    required this.sku,
    required this.qrCode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockAlert,
  });

  @override
  List<Object?> get props => [
        name,
        sku,
        qrCode,
        costPrice,
        sellingPrice,
        stockQuantity,
        minStockAlert,
      ];
}
