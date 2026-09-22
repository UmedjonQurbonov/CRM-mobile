import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import 'order_response_model.dart';

/// Data model representing http.OrderListResponse.
class OrderListResponseModel extends Equatable {
  final List<OrderResponseModel> items;
  final int total;
  final int limit;
  final int offset;

  const OrderListResponseModel({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory OrderListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['items'] as List<dynamic>? ?? [];
    final items = rawList
        .map((item) => OrderResponseModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderListResponseModel(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }

  bool get hasMore => (offset + items.length) < total;

  OrderListEntity toEntity() => OrderListEntity(
        items: items.map((m) => m.toEntity()).toList(),
        total: total,
        limit: limit,
        offset: offset,
      );

  @override
  List<Object?> get props => [items, total, limit, offset];
}
