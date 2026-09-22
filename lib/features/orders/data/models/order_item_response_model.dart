import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

/// Data model representing usecase.OrderItemResponseDTO.
class OrderItemResponseModel extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final Decimal unitPrice;
  final Decimal subtotal;

  const OrderItemResponseModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderItemResponseModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: _parseDecimal(json['unit_price']),
      subtotal: _parseDecimal(json['subtotal']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice.toString(),
        'subtotal': subtotal.toString(),
      };

  OrderItemEntity toEntity() => OrderItemEntity(
        id: id,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        subtotal: subtotal,
      );

  static Decimal _parseDecimal(dynamic value) {
    if (value == null) return Decimal.zero;
    if (value is num) return Decimal.parse(value.toString());
    if (value is String) {
      return Decimal.tryParse(value) ?? Decimal.zero;
    }
    return Decimal.zero;
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        quantity,
        unitPrice,
        subtotal,
      ];
}
