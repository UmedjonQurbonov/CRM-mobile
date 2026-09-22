import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Core domain entity for retail inventory products.
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String sku;
  final String qrCode;
  final Decimal costPrice;
  final Decimal sellingPrice;
  final int stockQuantity;
  final int minStockAlert;
  final bool isLowStock;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    required this.qrCode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockAlert,
    required this.isLowStock,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if item has completely ran out of inventory.
  bool get isOutOfStock => stockQuantity <= 0;

  /// Gross margin per unit for owner view.
  Decimal get unitMargin => sellingPrice - costPrice;

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        qrCode,
        costPrice,
        sellingPrice,
        stockQuantity,
        minStockAlert,
        isLowStock,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Paginated list entity of products.
class ProductListEntity extends Equatable {
  final List<ProductEntity> items;
  final int total;
  final int limit;
  final int offset;

  const ProductListEntity({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  bool get hasMore => (offset + items.length) < total;

  @override
  List<Object?> get props => [items, total, limit, offset];
}
