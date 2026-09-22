import 'package:decimal/decimal.dart';
import '../../domain/entities/product_entity.dart';

/// Data model representing usecase.ProductResponseDTO from OpenAPI schema.
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.qrCode,
    required super.costPrice,
    required super.sellingPrice,
    required super.stockQuantity,
    required super.minStockAlert,
    required super.isLowStock,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final stock = (json['stock_quantity'] as num?)?.toInt() ?? 0;
    final minAlert = (json['min_stock_alert'] as num?)?.toInt() ?? 0;

    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      qrCode: json['qr_code'] as String? ?? '',
      costPrice: _parseDecimal(json['cost_price']),
      sellingPrice: _parseDecimal(json['selling_price']),
      stockQuantity: stock,
      minStockAlert: minAlert,
      isLowStock: json['is_low_stock'] as bool? ?? (minAlert > 0 && stock <= minAlert),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'qr_code': qrCode,
        'cost_price': costPrice.toString(),
        'selling_price': sellingPrice.toString(),
        'stock_quantity': stockQuantity,
        'min_stock_alert': minStockAlert,
        'is_low_stock': isLowStock,
        'is_active': isActive,
        if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      };

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        sku: sku,
        qrCode: qrCode,
        costPrice: costPrice,
        sellingPrice: sellingPrice,
        stockQuantity: stockQuantity,
        minStockAlert: minStockAlert,
        isLowStock: isLowStock,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static Decimal _parseDecimal(dynamic value) {
    if (value == null) return Decimal.zero;
    if (value is num) return Decimal.parse(value.toString());
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '').trim();
      return Decimal.tryParse(cleaned) ?? Decimal.zero;
    }
    return Decimal.zero;
  }
}
