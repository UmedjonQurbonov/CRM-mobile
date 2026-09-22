import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_response_model.dart';

/// Data model representing usecase.OrderResponseDTO.
class OrderResponseModel extends Equatable {
  final String id;
  final String sellerId;
  final Decimal totalAmount;
  final Decimal commissionRateSnapshot;
  final Decimal commissionEarned;
  final String paymentMethod;
  final String status;
  final List<OrderItemResponseModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderResponseModel({
    required this.id,
    required this.sellerId,
    required this.totalAmount,
    required this.commissionRateSnapshot,
    required this.commissionEarned,
    required this.paymentMethod,
    required this.status,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((item) =>
            OrderItemResponseModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderResponseModel(
      id: json['id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      totalAmount: _parseDecimal(json['total_amount']),
      commissionRateSnapshot: _parseDecimal(json['commission_rate_snapshot']),
      commissionEarned: _parseDecimal(json['commission_earned']),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      status: json['status'] as String? ?? 'completed',
      items: items,
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
        'seller_id': sellerId,
        'total_amount': totalAmount.toString(),
        'commission_rate_snapshot': commissionRateSnapshot.toString(),
        'commission_earned': commissionEarned.toString(),
        'payment_method': paymentMethod,
        'status': status,
        'items': items.map((i) => i.toJson()).toList(),
        if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      };

  OrderEntity toEntity() => OrderEntity(
        id: id,
        sellerId: sellerId,
        totalAmount: totalAmount,
        commissionRateSnapshot: commissionRateSnapshot,
        commissionEarned: commissionEarned,
        paymentMethod: paymentMethod,
        status: status,
        items: items.map((i) => i.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
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
        sellerId,
        totalAmount,
        commissionRateSnapshot,
        commissionEarned,
        paymentMethod,
        status,
        items,
        createdAt,
        updatedAt,
      ];
}
