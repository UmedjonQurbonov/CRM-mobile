import 'package:intl/intl.dart';
import '../../domain/entities/create_expense_params.dart';

/// Request body DTO mapping to `http.CreateExpenseRequest`.
class CreateExpenseRequestModel {
  final String amount;
  final String category;
  final String comment;
  final String expenseDate;

  const CreateExpenseRequestModel({
    required this.amount,
    required this.category,
    required this.comment,
    required this.expenseDate,
  });

  factory CreateExpenseRequestModel.fromEntity(CreateExpenseParams params) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(params.expenseDate);
    return CreateExpenseRequestModel(
      amount: params.amount.toString(),
      category: params.category,
      comment: params.comment,
      expenseDate: formattedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'comment': comment,
      'expense_date': expenseDate,
    };
  }
}
