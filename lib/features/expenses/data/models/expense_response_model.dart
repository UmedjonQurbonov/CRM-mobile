import 'package:decimal/decimal.dart';
import '../../domain/entities/expense_entity.dart';

/// DTO for parsing `usecase.ExpenseResponseDTO` from the backend.
class ExpenseResponseModel extends ExpenseEntity {
  const ExpenseResponseModel({
    required super.id,
    required super.amount,
    required super.category,
    required super.comment,
    required super.expenseDate,
    super.createdBy,
    super.createdAt,
  });

  factory ExpenseResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse Decimal amount from string or num safely
    final rawAmount = json['amount'];
    final Decimal amount = rawAmount != null
        ? Decimal.parse(rawAmount.toString())
        : Decimal.zero;

    // Parse expenseDate (supports 'YYYY-MM-DD' and ISO8601)
    final rawExpenseDate = json['expense_date']?.toString() ?? '';
    final DateTime expenseDate = DateTime.tryParse(rawExpenseDate) ?? DateTime.now();

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    return ExpenseResponseModel(
      id: json['id'] as String? ?? '',
      amount: amount,
      category: json['category'] as String? ?? 'other',
      comment: json['comment'] as String? ?? '',
      expenseDate: expenseDate,
      createdBy: json['created_by'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount.toString(),
      'category': category,
      'comment': comment,
      'expense_date':
          '${expenseDate.year.toString().padLeft(4, '0')}-${expenseDate.month.toString().padLeft(2, '0')}-${expenseDate.day.toString().padLeft(2, '0')}',
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
