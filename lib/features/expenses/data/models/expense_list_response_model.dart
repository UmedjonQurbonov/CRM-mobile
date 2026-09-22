import '../../domain/entities/expense_entity.dart';
import 'expense_response_model.dart';

/// DTO for parsing paginated operational expenses response (`http.ExpenseListResponse`).
class ExpenseListResponseModel extends ExpenseListEntity {
  const ExpenseListResponseModel({
    required super.items,
    required super.total,
    required super.limit,
    required super.offset,
    required super.hasMore,
  });

  factory ExpenseListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => ExpenseResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final total = (json['total'] as num?)?.toInt() ?? items.length;
    final limit = (json['limit'] as num?)?.toInt() ?? 20;
    final offset = (json['offset'] as num?)?.toInt() ?? 0;
    final hasMore = (offset + items.length) < total;

    return ExpenseListResponseModel(
      items: items,
      total: total,
      limit: limit,
      offset: offset,
      hasMore: hasMore,
    );
  }
}
