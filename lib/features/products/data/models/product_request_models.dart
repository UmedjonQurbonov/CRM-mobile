import 'package:equatable/equatable.dart';
import '../../domain/entities/product_params.dart';

/// Request model for creating a product (POST /api/v1/products).
class CreateProductRequestModel extends Equatable {
  final String name;
  final String sku;
  final String qrCode;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minStockAlert;

  const CreateProductRequestModel({
    required this.name,
    required this.sku,
    required this.qrCode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockAlert,
  });

  factory CreateProductRequestModel.fromParams(CreateProductParams params) {
    return CreateProductRequestModel(
      name: params.name,
      sku: params.sku,
      qrCode: params.qrCode,
      costPrice: params.costPrice.toDouble(),
      sellingPrice: params.sellingPrice.toDouble(),
      stockQuantity: params.stockQuantity,
      minStockAlert: params.minStockAlert,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sku': sku,
        'qr_code': qrCode,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'stock_quantity': stockQuantity,
        'min_stock_alert': minStockAlert,
      };

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

/// Request model for updating a product (PUT /api/v1/products/{id}).
class UpdateProductRequestModel extends Equatable {
  final String name;
  final String sku;
  final String qrCode;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minStockAlert;

  const UpdateProductRequestModel({
    required this.name,
    required this.sku,
    required this.qrCode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockAlert,
  });

  factory UpdateProductRequestModel.fromParams(UpdateProductParams params) {
    return UpdateProductRequestModel(
      name: params.name,
      sku: params.sku,
      qrCode: params.qrCode,
      costPrice: params.costPrice.toDouble(),
      sellingPrice: params.sellingPrice.toDouble(),
      stockQuantity: params.stockQuantity,
      minStockAlert: params.minStockAlert,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sku': sku,
        'qr_code': qrCode,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'stock_quantity': stockQuantity,
        'min_stock_alert': minStockAlert,
      };

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
