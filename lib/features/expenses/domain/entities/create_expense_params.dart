import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Parameters for recording a new operational expense.
class CreateExpenseParams extends Equatable {
  final Decimal amount;
  final String category;
  final String comment;
  final DateTime expenseDate;

  const CreateExpenseParams({
    required this.amount,
    required this.category,
    required this.comment,
    required this.expenseDate,
  });

  @override
  List<Object?> get props => [amount, category, comment, expenseDate];
}
