import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';
import 'product_model.dart';

/// Data model representing http.ProductListResponse from OpenAPI schema.
class ProductListResponseModel extends Equatable {
  final List<ProductModel> items;
  final int total;
  final int limit;
  final int offset;

  const ProductListResponseModel({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['items'] as List<dynamic>? ?? [];
    final items = rawList
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ProductListResponseModel(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }

  bool get hasMore => (offset + items.length) < total;

  ProductListEntity toEntity() => ProductListEntity(
        items: items.map((m) => m.toEntity()).toList(),
        total: total,
        limit: limit,
        offset: offset,
      );

  @override
  List<Object?> get props => [items, total, limit, offset];
}
